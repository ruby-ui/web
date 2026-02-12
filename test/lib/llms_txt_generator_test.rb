# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"

require_relative "../../lib/llms_txt_generator"

class LlmsTxtGeneratorTest < Minitest::Test
  def setup
    @docs_dir = File.expand_path("../../app/views/docs", __dir__)
    @generator = LlmsTxtGenerator.new(docs_dir: @docs_dir)
  end

  # --- extract_header ---

  def test_extract_header_with_string_title
    # button.rb uses: Docs::Header.new(title: "Button", description: "...")
    # but actually it uses a variable. Let's use alert.rb which uses a string directly
    result = @generator.extract_header(File.join(@docs_dir, "alert.rb"))
    assert_equal "Alert", result[0]
    assert_equal "Displays a callout for user attention.", result[1]
  end

  def test_extract_header_with_variable_title
    # button.rb assigns component = "Button" then uses Docs::Header.new(title: component, ...)
    result = @generator.extract_header(File.join(@docs_dir, "button.rb"))
    assert_equal "Button", result[0]
    assert_includes result[1], "button"
  end

  def test_extract_header_returns_nil_for_non_doc_file
    # base.rb has no Docs::Header
    result = @generator.extract_header(File.join(@docs_dir, "..", "base.rb"))
    assert_nil result
  end

  def test_extract_header_with_fixture_string_title
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "widget.rb"), <<~RUBY)
        class Views::Docs::Widget < Views::Base
          def view_template
            render Docs::Header.new(title: "Widget", description: "A fancy widget component.")
          end
        end
      RUBY

      result = @generator.extract_header(File.join(dir, "widget.rb"))
      assert_equal ["Widget", "A fancy widget component."], result
    end
  end

  def test_extract_header_with_fixture_variable_title
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "gadget.rb"), <<~RUBY)
        class Views::Docs::Gadget < Views::Base
          def view_template
            component = "Gadget"
            render Docs::Header.new(title: component, description: "A useful gadget.")
          end
        end
      RUBY

      result = @generator.extract_header(File.join(dir, "gadget.rb"))
      assert_equal ["Gadget", "A useful gadget."], result
    end
  end

  # --- collect_components ---

  def test_collect_components_returns_all_categories
    components = @generator.collect_components
    assert_includes components.keys, "Form & Input"
    assert_includes components.keys, "Layout & Navigation"
    assert_includes components.keys, "Overlays & Dialogs"
    assert_includes components.keys, "Feedback & Status"
    assert_includes components.keys, "Display & Media"
  end

  def test_collect_components_finds_all_45_components
    components = @generator.collect_components
    total = components.values.sum(&:length)
    assert_equal 45, total, "Expected 45 components, got #{total}"
  end

  def test_collect_components_skips_base_rb
    components = @generator.collect_components
    all_slugs = components.values.flat_map { |items| items.map { |c| c[:slug] } }
    refute_includes all_slugs, "base"
  end

  def test_collect_components_has_correct_structure
    components = @generator.collect_components
    sample = components.values.first.first
    assert_kind_of Hash, sample
    assert sample.key?(:slug)
    assert sample.key?(:title)
    assert sample.key?(:description)
  end

  def test_collect_components_categorizes_button_as_form_input
    components = @generator.collect_components
    slugs = components["Form & Input"].map { |c| c[:slug] }
    assert_includes slugs, "button"
  end

  def test_collect_components_categorizes_dialog_as_overlays
    components = @generator.collect_components
    slugs = components["Overlays & Dialogs"].map { |c| c[:slug] }
    assert_includes slugs, "dialog"
  end

  def test_collect_components_uncategorized_goes_to_miscellaneous
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "unknown_thing.rb"), <<~RUBY)
        class Views::Docs::UnknownThing < Views::Base
          def view_template
            render Docs::Header.new(title: "Unknown", description: "Mystery component.")
          end
        end
      RUBY

      gen = LlmsTxtGenerator.new(docs_dir: dir)
      components = gen.collect_components
      assert_equal 1, components["Miscellaneous"].length
      assert_equal "Unknown", components["Miscellaneous"].first[:title]
    end
  end

  # --- generate ---

  def test_generate_starts_with_h1
    content = @generator.generate
    assert content.start_with?("# RubyUI"), "Expected llms.txt to start with '# RubyUI'"
  end

  def test_generate_has_blockquote_summary
    content = @generator.generate
    assert_includes content, "> RubyUI is a UI component library"
  end

  def test_generate_has_getting_started_section
    content = @generator.generate
    assert_includes content, "## Getting Started"
    assert_includes content, "[Introduction]"
    assert_includes content, "[Installation]"
    assert_includes content, "[Theming]"
    assert_includes content, "[Dark Mode]"
    assert_includes content, "[Customizing Components]"
    assert_includes content, "[LLMs.txt]"
  end

  def test_generate_has_components_section
    content = @generator.generate
    assert_includes content, "## Components"
    assert_includes content, "### Form & Input"
    assert_includes content, "### Layout & Navigation"
    assert_includes content, "### Overlays & Dialogs"
    assert_includes content, "### Feedback & Status"
    assert_includes content, "### Display & Media"
  end

  def test_generate_uses_correct_base_url
    gen = LlmsTxtGenerator.new(docs_dir: @docs_dir, base_url: "https://example.com")
    content = gen.generate
    assert_includes content, "https://example.com/docs/button"
    refute_includes content, "https://rubyui.com"
  end

  def test_generate_strips_trailing_slash_from_base_url
    gen = LlmsTxtGenerator.new(docs_dir: @docs_dir, base_url: "https://example.com/")
    content = gen.generate
    assert_includes content, "https://example.com/docs/button"
    refute_includes content, "https://example.com//docs"
  end

  def test_generate_uses_markdown_link_format
    content = @generator.generate
    # Each component line should match: - [Title](url): Description
    component_lines = content.lines.select { |l| l.match?(/^- \[.+\]\(https:\/\//) }
    assert component_lines.length >= 45, "Expected at least 45 component links"
    component_lines.each do |line|
      assert_match(/^- \[.+\]\(https:\/\/.+\): .+/, line.chomp,
        "Line does not match llms.txt link format: #{line.chomp}")
    end
  end

  def test_generate_sorts_components_alphabetically_within_category
    content = @generator.generate
    # Extract Form & Input section
    section = content[/### Form & Input\n\n(.*?)\n\n###/m, 1]
    titles = section.scan(/\[([^\]]+)\]/).flatten
    assert_equal titles, titles.sort, "Form & Input components should be alphabetically sorted"
  end

  def test_generate_does_not_include_miscellaneous_when_all_categorized
    content = @generator.generate
    refute_includes content, "### Miscellaneous"
  end

  # --- write ---

  def test_write_creates_file
    Dir.mktmpdir do |dir|
      path = File.join(dir, "llms.txt")
      @generator.write(path)
      assert File.exist?(path)
    end
  end

  def test_write_returns_component_count
    Dir.mktmpdir do |dir|
      path = File.join(dir, "llms.txt")
      count = @generator.write(path)
      assert_equal 45, count
    end
  end

  def test_write_content_matches_generate
    Dir.mktmpdir do |dir|
      path = File.join(dir, "llms.txt")
      @generator.write(path)
      assert_equal @generator.generate, File.read(path)
    end
  end

  # --- llms.txt spec compliance ---

  def test_spec_only_one_h1
    content = @generator.generate
    h1_count = content.lines.count { |l| l.match?(/^# \w/) }
    assert_equal 1, h1_count, "llms.txt spec requires exactly one H1 heading"
  end

  def test_spec_h1_is_first_line
    content = @generator.generate
    assert content.lines.first.start_with?("# "), "H1 must be the first line per spec"
  end

  def test_spec_blockquote_follows_h1
    content = @generator.generate
    lines = content.lines.map(&:chomp)
    h1_idx = lines.index { |l| l.start_with?("# ") }
    # Next non-empty line should be the blockquote
    next_content = lines[(h1_idx + 1)..].find { |l| !l.strip.empty? }
    assert next_content.start_with?("> "), "Blockquote summary should follow H1 per spec"
  end

  def test_spec_sections_use_h2
    content = @generator.generate
    h2_lines = content.lines.select { |l| l.start_with?("## ") }
    assert h2_lines.length >= 2, "Expected at least 2 H2 sections (Getting Started + Components)"
  end

  def test_spec_file_lists_use_markdown_links
    content = @generator.generate
    list_lines = content.lines.select { |l| l.start_with?("- [") }
    list_lines.each do |line|
      assert_match(/^- \[.+\]\(.+\)/, line.chomp, "File list entries must use markdown links")
    end
  end

  # --- idempotency ---

  def test_generate_is_idempotent
    first = @generator.generate
    second = @generator.generate
    assert_equal first, second, "Generating twice should produce identical output"
  end

  # --- public/llms.txt is in sync ---

  def test_public_llms_txt_matches_generated_output
    public_path = File.expand_path("../../public/llms.txt", __dir__)
    skip "public/llms.txt does not exist" unless File.exist?(public_path)

    expected = @generator.generate
    actual = File.read(public_path)
    assert_equal expected, actual,
      "public/llms.txt is out of sync with generator. Run: rake llms:generate"
  end
end
