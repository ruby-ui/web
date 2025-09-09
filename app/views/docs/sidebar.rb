# frozen_string_literal: true

class Views::Docs::Sidebar < Views::Base
  def view_template
    component = "Sidebar"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Sidebar", description: "A composable, themeable and customizable sidebar component.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", src: "/docs/sidebar/example", context: self) do
        Views::Docs::Sidebar::Example::CODE
      end

      render Docs::VisualCodeExample.new(title: "Inset variant", src: "/docs/sidebar/inset", context: self) do
        Views::Docs::Sidebar::InsetExample::CODE
      end

      render div do
        div do
          Components.Heading(level: 4) { "Dialog variant" }

          Tabs(default_value: "preview") do
            TabsList do
              TabsTrigger(value: "preview") do
                span { "Preview" }
              end
              TabsTrigger(value: "code") do
                span { "Code" }
              end
            end

            TabsContent(value: "preview") do
              Link(href: "/docs/sidebar/dialog", target: :_blank, variant: :primary) { "Open in another tab" }
            end

            TabsContent(value: "code") do
              div(class: "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border") do
                Codeblock(Views::Docs::Sidebar::DialogExample::CODE, syntax: :ruby, class: "-m-px")
              end
            end
          end
        end
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
