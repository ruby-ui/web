# frozen_string_literal: true

class Views::Docs::GettingStarted::LlmsTxt < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "LLMs.txt", description: "LLM-friendly documentation for AI-assisted development with RubyUI.")

      div(class: "space-y-4") do
        Heading(level: 2) { "What is llms.txt?" }
        Text do
          InlineLink(href: "https://llmstxt.org") { "llms.txt" }
          plain " is a standard for providing LLM-friendly documentation. It gives AI tools a structured overview of a project's docs so they can help you build with RubyUI more effectively."
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "Available files" }
        Text { "RubyUI provides the following file for AI consumption:" }
        Components.TypographyList do
          Components.TypographyListItem do
            InlineLink(href: "/llms.txt") { "/llms.txt" }
            plain " — Component index with descriptions and links to documentation pages."
          end
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "Using with AI tools" }
        Text { "You can use the llms.txt file with AI coding assistants to help them understand RubyUI's component library. Here are some examples:" }
        Components.TypographyList do
          Components.TypographyListItem do
            span(class: "font-medium") { "Claude Code / Cursor: " }
            plain "Point the AI to https://rubyui.com/llms.txt for context on available components."
          end
          Components.TypographyListItem do
            span(class: "font-medium") { "Custom tooling: " }
            plain "Fetch /llms.txt at inference time to give your LLM up-to-date component information."
          end
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "Keeping it updated" }
        Text do
          plain "The llms.txt file is generated from the doc source files. If you're contributing to RubyUI, you can regenerate it with:"
        end
        Codeblock("rake llms:generate", syntax: :bash)
        Text do
          plain "This parses the component view files in "
          InlineCode { "app/views/docs/" }
          plain " and outputs "
          InlineCode { "public/llms.txt" }
          plain "."
        end
      end
    end
  end
end
