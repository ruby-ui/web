# frozen_string_literal: true

# Rake task to generate /public/llms.txt from doc views and routes.
#
# Usage:
#   rake llms:generate
#   rake llms:generate[https://rubyui.com]  # custom base URL
#
# Run this after adding/removing components to keep llms.txt in sync.

namespace :llms do
  desc "Generate public/llms.txt from doc view files"
  task :generate, [:base_url] do |_t, args|
    base_url = (args[:base_url] || "https://rubyui.com").chomp("/")
    docs_dir = File.expand_path("../../app/views/docs", __dir__)

    # Category mapping: filename => [category, subcategory]
    categories = {
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
    }

    # Parse title and description from a doc view .rb file
    def extract_header(file_path)
      content = File.read(file_path)
      if content =~ /Docs::Header\.new\(title:\s*(?:"([^"]+)"|'([^']+)'|(\w+))\s*,\s*description:\s*"([^"]+)"/
        title = $1 || $2 || $3
        description = $4
        # If title is a variable reference (like `component`), look for the assignment
        if title =~ /\A[a-z_]+\z/
          content.match(/#{title}\s*=\s*"([^"]+)"/) { |m| title = m[1] }
        end
        [title, description]
      end
    end

    # Collect components
    components_by_category = Hash.new { |h, k| h[k] = [] }
    Dir.glob(File.join(docs_dir, "*.rb")).each do |file|
      next if File.basename(file) == "base.rb"

      slug = File.basename(file, ".rb")
      result = extract_header(file)
      next unless result

      title, description = result
      category = categories[slug] || "Miscellaneous"
      components_by_category[category] << { slug: slug, title: title, description: description }
    end

    # Build llms.txt
    lines = []
    lines << "# RubyUI"
    lines << ""
    lines << "> RubyUI is a UI component library for Ruby developers, built on top of Phlex, TailwindCSS, and Stimulus JS. Components are inspired by shadcn/ui and use compatible theming with CSS variables. Install via the ruby_ui gem into any Rails application. Components are written in pure Ruby using Phlex (up to 12x faster than ERB) and use custom Stimulus.js controllers for interactivity."
    lines << ""

    # Getting Started section
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

    # Components section
    lines << "## Components"
    lines << ""

    category_order = ["Form & Input", "Layout & Navigation", "Overlays & Dialogs", "Feedback & Status", "Display & Media", "Miscellaneous"]
    category_order.each do |category|
      next unless components_by_category.key?(category)

      items = components_by_category[category].sort_by { |c| c[:title] }
      lines << "### #{category}"
      lines << ""
      items.each do |comp|
        lines << "- [#{comp[:title]}](#{base_url}/docs/#{comp[:slug]}): #{comp[:description]}"
      end
      lines << ""
    end

    output_path = File.expand_path("../../public/llms.txt", __dir__)
    File.write(output_path, lines.join("\n"))
    puts "Generated #{output_path} (#{components_by_category.values.sum(&:length)} components)"
  end
end
