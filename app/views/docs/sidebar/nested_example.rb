# frozen_string_literal: true

class Views::Docs::Sidebar::NestedExample < Views::Base
  FAVORITES = [
    {name: "Project Management & Task Tracking", emoji: "\u{1F4CA}"},
    {name: "Movies & TV Shows", emoji: "\u{1F3AC}"},
    {name: "Books & Articles", emoji: "\u{1F4DA}"},
    {name: "Recipes & Meal Planning", emoji: "\u{1F37D}\u{FE0F}"},
    {name: "Travel & Places", emoji: "\u{1F30D}"},
    {name: "Health & Fitness", emoji: "\u{1F3CB}\u{FE0F}"}
  ].freeze

  WORKSPACES = [
    {name: "Personal Life Management", emoji: "\u{1F3E1}"},
    {name: "Work & Projects", emoji: "\u{1F4BC}"},
    {name: "Side Projects", emoji: "\u{1F680}"},
    {name: "Learning & Courses", emoji: "\u{1F4DA}"},
    {name: "Writing & Blogging", emoji: "\u{270D}\u{FE0F}"},
    {name: "Design & Development", emoji: "\u{1F3A8}"}
  ].freeze

  def initialize(sidebar_state:)
    @sidebar_state = sidebar_state
  end

  CODE = <<~RUBY
    SidebarWrapper do
      Sidebar(collapsible: :icon, variant: :inset) do
        div(class: "flex h-full", data: {controller: "nested-sidebar", nested_sidebar_active_value: "home"}) do
          # Icon rail
          div(class: "flex flex-col items-center w-12 shrink-0 border-r border-sidebar-border py-4") do
            div(class: "flex flex-col items-center gap-1") do
              icon_rail_button("home", active: true) { home_icon() }
              icon_rail_button("favorites") { star_icon() }
              icon_rail_button("workspaces") { briefcase_icon() }
              icon_rail_button("settings") { settings_icon() }
            end
            div(class: "mt-auto") do
              DropdownMenu(options: {strategy: "fixed", placement: "right-end"}) do
                button(
                  type: "button",
                  class: "flex items-center justify-center size-8 shrink-0 rounded-full bg-sidebar-accent text-sidebar-accent-foreground font-semibold text-sm",
                  data: {
                    ruby_ui__dropdown_menu_target: "trigger",
                    action: "click->ruby-ui--dropdown-menu#toggle"
                  }
                ) { "JD" }
                DropdownMenuContent(class: "min-w-56 rounded-lg z-50") do
                  DropdownMenuLabel do
                    div(class: "flex flex-col") do
                      span(class: "truncate font-semibold") { "John Doe" }
                      span(class: "truncate text-xs text-muted-foreground") { "john@example.com" }
                    end
                  end
                  DropdownMenuSeparator()
                  DropdownMenuItem(href: "#") { "Profile" }
                  DropdownMenuItem(href: "#") { "Billing" }
                  DropdownMenuItem(href: "#") { "Settings" }
                  DropdownMenuSeparator()
                  DropdownMenuItem(href: "#") { "Sign out" }
                end
              end
            end
          end

          # Content panels (one per icon, toggled by nested-sidebar controller)
          div(class: "flex-1 flex flex-col min-w-0 group-data-[collapsible=icon]:hidden") do
            # Home panel
            div(data: {nested_sidebar_target: "panel", section: "home"}) do
              SidebarContent do
                SidebarGroup do
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
                        SidebarMenuBadge { 4 }
                      end
                    end
                  end
                end
              end
            end

            # Favorites panel
            div(hidden: true, data: {nested_sidebar_target: "panel", section: "favorites"}) do
              SidebarContent do
                SidebarGroup do
                  SidebarGroupLabel { "Favorites" }
                  SidebarMenu do
                    FAVORITES.each do |item|
                      SidebarMenuItem do
                        SidebarMenuButton(as: :a, href: "#") do
                          span { item[:emoji] }
                          span { item[:name] }
                        end
                      end
                    end
                  end
                end
              end
            end

            # Workspaces panel
            div(hidden: true, data: {nested_sidebar_target: "panel", section: "workspaces"}) do
              SidebarContent do
                SidebarGroup do
                  SidebarGroupLabel { "Workspaces" }
                  SidebarMenu do
                    WORKSPACES.each do |item|
                      SidebarMenuItem do
                        SidebarMenuButton(as: :a, href: "#") do
                          span { item[:emoji] }
                          span { item[:name] }
                        end
                      end
                    end
                  end
                end
              end
            end

            # Settings panel
            div(hidden: true, data: {nested_sidebar_target: "panel", section: "settings"}) do
              SidebarContent do
                SidebarGroup do
                  SidebarGroupContent do
                    SidebarMenu do
                      SidebarMenuItem do
                        SidebarMenuButton(as: :a, href: "#") do
                          settings_icon()
                          span { "Settings" }
                        end
                      end
                      SidebarMenuItem do
                        SidebarMenuButton(as: :a, href: "#") do
                          message_circle_question_icon()
                          span { "Help & Support" }
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
        SidebarRail()
      end
      SidebarInset do
        header(class: "flex h-16 shrink-0 items-center gap-2 border-b px-4") do
          SidebarTrigger(class: "-ml-1")
        end
      end
    end
  RUBY

  def view_template
    decoded_code = CGI.unescapeHTML(CODE)
    instance_eval(decoded_code)
  end

  private

  def icon_rail_button(section, active: false, &block)
    classes = [
      "flex items-center justify-center size-8 rounded-md transition-colors [&>svg]:size-4 [&>svg]:shrink-0",
      "data-[active=true]:bg-sidebar-accent data-[active=true]:text-sidebar-accent-foreground",
      "data-[active=false]:text-sidebar-foreground/70 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
    ].join(" ")
    button(
      type: "button",
      class: classes,
      data: {
        nested_sidebar_target: "icon",
        section: section,
        action: "click->nested-sidebar#select",
        active: active
      },
      &block
    )
  end

  def home_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.path(d: "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8")
      s.path(d: "M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z")
    end
  end

  def star_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.path(d: "M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a.53.53 0 0 0 .4.29l5.16.756a.53.53 0 0 1 .294.904l-3.733 3.638a.53.53 0 0 0-.153.469l.882 5.14a.53.53 0 0 1-.77.56l-4.614-2.426a.53.53 0 0 0-.494 0L7.14 18.73a.53.53 0 0 1-.77-.56l.882-5.14a.53.53 0 0 0-.153-.47L3.365 8.925a.53.53 0 0 1 .294-.904l5.16-.756a.53.53 0 0 0 .4-.29z")
    end
  end

  def briefcase_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.path(d: "M16 20V4a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16")
      s.rect(width: "20", height: "14", x: "2", y: "6", rx: "2")
    end
  end

  def search_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.circle(cx: "11", cy: "11", r: "8")
      s.path(d: "M21 21L16.7 16.7")
    end
  end

  def inbox_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.polyline(points: "22 12 16 12 14 15 10 15 8 12 2 12")
      s.path(d: "M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z")
    end
  end

  def settings_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.path(d: "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z")
      s.circle(cx: "12", cy: "12", r: "3")
    end
  end

  def message_circle_question_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
      s.path(d: "M7.9 20A9 9 0 1 0 4 16.1L2 22Z")
      s.path(d: "M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3")
      s.path(d: "M12 17h.01")
    end
  end
end
