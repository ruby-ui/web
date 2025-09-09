# frozen_string_literal: true

class Views::Docs::Sidebar::DialogExample < Views::Base
  def initialize(sidebar_state:)
    @sidebar_state = sidebar_state
  end

  CODE = <<~RUBY
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

  def view_template
    decoded_code = CGI.unescapeHTML(CODE)
    instance_eval(decoded_code)
  end

  private

  def nav_secondary
    [
      {label: "Settings", icon: -> { settings_icon }},
      {label: "Help & Support", icon: -> { message_circle_question }}
    ]
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

  def calendar_icon
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
      class: "lucide lucide-calendar"
    ) do |s|
      s.path(d: "M8 2v4")
      s.path(d: "M16 2v4")
      s.rect(width: "18", height: "18", x: "3", y: "4", rx: "2")
      s.path(d: "M3 10h18")
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

  def settings_icon
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
      class: "lucide lucide-settings"
    ) do |s|
      s.path(d: "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73
      l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z")
      s.circle(cx: "12", cy: "12", r: "3")
    end
  end

  def plus_icon
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
      class: "lucide lucide-plus"
    ) do |s|
      s.path(d: "M5 12h14")
      s.path(d: "M12 5v14")
    end
  end

  def gallery_vertical_end
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", view_box: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "lucide lucide-gallery-vertical-end size-4") do |s|
      s.path d: "M7 2h10"
      s.path d: "M5 6h14"
      s.rect width: "18", height: "12", x: "3", y: "10", rx: "2"
    end
  end

  def ellipsis_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_line_join: "round", class: "lucide lucide-ellipsis-icon lucide-ellipsis") do |s|
      s.circle cx: "12", cy: "12", r: "1"
      s.circle cx: "19", cy: "12", r: "1"
      s.circle cx: "5", cy: "12", r: "1"
    end
  end

  def message_circle_question
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_line_join: "round", class: "lucide lucide-message-circle-question-icon lucide-message-circle-question") do |s|
      s.path d: "M7.9 20A9 9 0 1 0 4 16.1L2 22Z"
      s.path d: "M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"
      s.path d: "M12 17h.01"
    end
  end
end
