# frozen_string_literal: true

# Generates llms.txt content from RubyUI doc view files.
#
# Usage:
#   generator = LlmsTxtGenerator.new(docs_dir: "app/views/docs", base_url: "https://rubyui.com")
#   generator.generate          # returns the llms.txt content as a string
#   generator.write("public/llms.txt")  # writes to file
class LlmsTxtGenerator
  CATEGORIES = {
    # Form & Input
    "button" => "Form & Input",
    "input" => "Form & Input",
    "masked_input" => "Form & Input",
    "textarea" => "Form & Input",
    "checkbox" => "Form & Input",
    "checkbox_group" => "Form & Input",
    "radio_button" => "Form & Input",
    "select" => "Form & Input",
    "switch" => "Form & Input",
    "calendar" => "Form & Input",
    "date_picker" => "Form & Input",
    "combobox" => "Form & Input",
    "form" => "Form & Input",
    # Layout & Navigation
    "accordion" => "Layout & Navigation",
    "breadcrumb" => "Layout & Navigation",
    "tabs" => "Layout & Navigation",
    "sidebar" => "Layout & Navigation",
    "separator" => "Layout & Navigation",
    "pagination" => "Layout & Navigation",
    "link" => "Layout & Navigation",
    "collapsible" => "Layout & Navigation",
    # Overlays & Dialogs
    "dialog" => "Overlays & Dialogs",
    "alert_dialog" => "Overlays & Dialogs",
    "sheet" => "Overlays & Dialogs",
    "popover" => "Overlays & Dialogs",
    "tooltip" => "Overlays & Dialogs",
    "hover_card" => "Overlays & Dialogs",
    "context_menu" => "Overlays & Dialogs",
    "dropdown_menu" => "Overlays & Dialogs",
    "command" => "Overlays & Dialogs",
    # Feedback & Status
    "alert" => "Feedback & Status",
    "progress" => "Feedback & Status",
    "skeleton" => "Feedback & Status",
    "badge" => "Feedback & Status",
    # Display & Media
    "avatar" => "Display & Media",
    "card" => "Display & Media",
    "table" => "Display & Media",
    "chart" => "Display & Media",
    "carousel" => "Display & Media",
    "aspect_ratio" => "Display & Media",
    "typography" => "Display & Media",
    "codeblock" => "Display & Media",
    "clipboard" => "Display & Media",
    "shortcut_key" => "Display & Media",
    "theme_toggle" => "Display & Media"
  }.freeze

  CATEGORY_ORDER = [
    "Form & Input",
    "Layout & Navigation",
    "Overlays & Dialogs",
    "Feedback & Status",
    "Display & Media",
    "Miscellaneous"
  ].freeze

  HEADER = "RubyUI is a UI component library for Ruby developers, built on top of Phlex, TailwindCSS, " \
    "and Stimulus JS. Components are inspired by shadcn/ui and use compatible theming with CSS variables. " \
    "Install via the ruby_ui gem into any Rails application. Components are written in pure Ruby using " \
    "Phlex (up to 12x faster than ERB) and use custom Stimulus.js controllers for interactivity."

  attr_reader :docs_dir, :base_url

  def initialize(docs_dir:, base_url: "https://rubyui.com")
    @docs_dir = docs_dir
    @base_url = base_url.chomp("/")
  end

  # Parse title and description from a Docs::Header.new call in a view file.
  # Returns [title, description] or nil.
  def extract_header(file_path)
    content = File.read(file_path)
    if content =~ /Docs::Header\.new\(title:\s*(?:"([^"]+)"|'([^']+)'|(\w+))\s*,\s*description:\s*"([^"]+)"/
      title = $1 || $2 || $3
      description = $4
      # If title is a variable reference (like `component`), resolve it
      if title.match?(/\A[a-z_]+\z/)
        content.match(/#{title}\s*=\s*"([^"]+)"/) { |m| title = m[1] }
      end
      [title, description]
    end
  end

  # Scan docs_dir for component view files and return a hash of category => [components].
  def collect_components
    components_by_category = Hash.new { |h, k| h[k] = [] }

    Dir.glob(File.join(docs_dir, "*.rb")).each do |file|
      basename = File.basename(file)
      next if basename == "base.rb"

      slug = File.basename(file, ".rb")
      result = extract_header(file)
      next unless result

      title, description = result
      category = CATEGORIES[slug] || "Miscellaneous"
      components_by_category[category] << {slug: slug, title: title, description: description}
    end

    components_by_category
  end

  # Generate the full llms.txt content as a string.
  def generate
    components_by_category = collect_components
    lines = []

    lines << "# RubyUI"
    lines << ""
    lines << "> #{HEADER}"
    lines << ""

    # Getting Started
    lines << "## Getting Started"
    lines << ""
    lines << "- [Introduction](#{base_url}/docs/introduction): Overview of RubyUI, core ingredients (Phlex, TailwindCSS, Stimulus JS), and design philosophy."
    lines << "- [Installation](#{base_url}/docs/installation): How to install RubyUI in your Rails application."
    lines << "- [Installation with Rails Bundler](#{base_url}/docs/installation/rails_bundler): Setup using Rails with bundler and JS bundling."
    lines << "- [Installation with Rails Importmaps](#{base_url}/docs/installation/rails_importmaps): Setup using Rails with importmaps."
    lines << "- [Theming](#{base_url}/docs/theming): Guide to customizing colors and design tokens using CSS variables."
    lines << "- [Dark Mode](#{base_url}/docs/dark_mode): How to implement dark mode support."
    lines << "- [Customizing Components](#{base_url}/docs/customizing_components): How to customize and extend RubyUI components."
    lines << ""

    # Components
    lines << "## Components"
    lines << ""

    CATEGORY_ORDER.each do |category|
      next unless components_by_category.key?(category)

      items = components_by_category[category].sort_by { |c| c[:title] }
      lines << "### #{category}"
      lines << ""
      items.each do |comp|
        lines << "- [#{comp[:title]}](#{base_url}/docs/#{comp[:slug]}): #{comp[:description]}"
      end
      lines << ""
    end

    lines.join("\n")
  end

  # Generate and write to a file. Returns the number of components found.
  def write(output_path)
    content = generate
    File.write(output_path, content)
    collect_components.values.sum(&:length)
  end
end
