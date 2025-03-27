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

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
