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

      render Docs::VisualCodeExample.new(title: "Dialog variant", context: self) do
        <<~RUBY
          Dialog(data: {action: "ruby-ui--dialog:connect->ruby-ui--dialog#open"}) do
            DialogTrigger do
              Button { "Open Dialog" }
            end
            DialogContent(class: "grid overflow-hidden p-0 md:max-h-[500px] md:max-w-[700px] lg:max-w-[800px]") do
              SidebarWrapper(class: "items-start") do
                Sidebar(collapsible: :none, class: "hidden md:flex") do
                  SidebarContent do
                    SidebarGroup do
                      SidebarGroupContent do
                        SidebarMenu do
                          SidebarMenuItem do
                            SidebarMenuButton(as: :a, href: "#") do
                              search_icon()
                              span { "Search" }
                            end
                          end
                          SidebarMenuItem do
                            SidebarMenuButton(as: :a, href: "#", active: true) do
                              home_icon()
                              span { "Home" }
                            end
                          end
                          SidebarMenuItem do
                            SidebarMenuButton(as: :a, href: "#") do
                              inbox_icon()
                              span { "Inbox" }
                            end
                          end
                        end
                      end
                    end
                  end
                end
                main(class: "flex h-[480px] flex-1 flex-col overflow-hidden") do
                end
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  def search_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-search"
    ) do |s|
      s.circle(cx: "11", cy: "11", r: "8")
      s.path(d: "M21 21L16.7 16.7")
    end
  end

  def home_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-house"
    ) do |s|
      s.path(d: "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8")
      s.path(d: "M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z")
    end
  end

  def inbox_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-inbox"
    ) do |s|
      s.polyline(points: "22 12 16 12 14 15 10 15 8 12 2 12")
      s.path(d: "M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z")
    end
  end
end
