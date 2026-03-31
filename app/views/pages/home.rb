# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    # Hero Section
    section(class: "space-y-6 pt-6 md:pt-10 lg:pt-16") do
      div(class: "container flex max-w-[64rem] flex-col items-center gap-4 text-center mx-auto") do
        Link(href: docs_changelog_path, variant: :outline, class: "rounded-2xl px-4 py-1.5 text-sm font-medium") do
          span(class: "sm:hidden") { "New components available" }
          span(class: "hidden sm:inline") { "Combobox updates and more" }
          svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "ml-2 h-4 w-4") { |s| s.path(d: "M5 12h14"); s.path(d: "m12 5 7 7-7 7") }
        end
        h1(class: "leading-tighter text-3xl font-semibold tracking-tight text-balance text-primary lg:leading-[1.1] lg:font-semibold xl:text-5xl xl:tracking-tighter max-w-4xl") do
          "Build sharp Ruby interfaces."
        end
        p(class: "max-w-4xl text-base text-balance text-foreground sm:text-lg") do
          "A UI component library, crafted precisely for Ruby devs who want to stay organised and build modern apps, fast."
        end
        div(class: "space-x-4 mt-4") do
          Link(href: docs_introduction_path, variant: :primary, size: :lg) { "Documentation" }
          Link(href: docs_components_path, variant: :outline, size: :lg) { "View Components" }
        end
      end
    end

    # Components Mosaic Section
    section(class: "container py-8 md:py-12 lg:py-24 mx-auto max-w-6xl") do
      div(class: "mx-auto flex max-w-[58rem] flex-col items-center space-y-4 text-center mb-12") do
        h2(class: "scroll-m-24 text-4xl font-semibold tracking-tight") { "Modern components for modern applications" }
        p(class: "max-w-[85%] leading-normal text-foreground sm:text-lg sm:leading-7") do
          "Every component is built with Ruby, Phlex, and Tailwind CSS. No more context switching between languages."
        end
      end

      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
        # COLUMN 1
        div(class: "space-y-6") do
          # PAYMENT CARD
          Card do
            CardHeader do
              CardTitle { "Payment Method" }
              CardDescription { "All transactions are secure and encrypted." }
            end
            CardContent(class: "space-y-4") do
              div(class: "space-y-2") do
                label { "Name on Card" }
                Input(placeholder: "John Doe")
              end
              div(class: "grid grid-cols-2 gap-4") do
                div(class: "space-y-2") do
                  label { "Month" }
                  Input(placeholder: "MM")
                end
                div(class: "space-y-2") do
                  label { "Year" }
                  Input(placeholder: "YYYY")
                end
              end
              div(class: "space-y-2") do
                label { "CVV" }
                Input(placeholder: "123")
              end
            end
            CardFooter do
              Button(class: "w-full") { "Add Payment" }
            end
          end

          # BADGES Showcase
          Card do
            CardContent(class: "pt-6 flex flex-wrap gap-2") do
              Badge(variant: :default) { "Syncing" }
              Badge(variant: :secondary) { "Updating" }
              Badge(variant: :outline) { "Loading" }
              Badge(variant: :destructive) { "Failed" }
            end
          end
        end

        # COLUMN 2
        div(class: "space-y-6") do
          # TEAM MEMBERS
          Card do
            CardHeader do
              CardTitle { "Team Members" }
              CardDescription { "Collaborate with your team." }
            end
            CardContent(class: "space-y-6") do
              team_member("Sofia Davis", "@sdavis", "https://i.pravatar.cc/150?u=sofia")
              team_member("Jackson Lee", "@jlee", "https://i.pravatar.cc/150?u=jackson")
              team_member("Isabella Nguyen", "@isabella", "https://i.pravatar.cc/150?u=isabella")
            end
            CardFooter do
              Button(variant: :outline, class: "w-full") { "Invite Members" }
            end
          end

          # NOTIFICATIONS
          Card do
            CardHeader do
              CardTitle { "Activity" }
              CardDescription { "Last 24 hours" }
            end
            CardContent(class: "space-y-4") do
              activity_item("New deployment", "2 minutes ago", :success)
              activity_item("Database backup", "3 hours ago", :info)
              activity_item("Security alert", "5 hours ago", :warning)
            end
          end
        end

        # COLUMN 3
        div(class: "space-y-6") do
          # SETTINGS / SWITCHES
          Card do
            CardHeader do
              CardTitle { "Compute Environment" }
              CardDescription { "Select your target cluster." }
            end
            CardContent(class: "space-y-4") do
              div(class: "flex items-center justify-between rounded-lg border p-4 shadow-sm") do
                div(class: "space-y-0.5") do
                  p(class: "font-medium") { "Kubernetes" }
                  p(class: "text-xs text-muted-foreground") { "Highly available cluster." }
                end
                Switch(checked: true)
              end
              div(class: "flex items-center justify-between rounded-lg border p-4 shadow-sm") do
                div(class: "space-y-0.5") do
                  p(class: "font-medium") { "Virtual Machine" }
                  p(class: "text-xs text-muted-foreground") { "Dedicated server." }
                end
                Switch()
              end
            end
          end

          # CHAT / MESSAGE
          Card do
            CardHeader(class: "pb-2") do
              div(class: "flex items-center gap-2") do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://i.pravatar.cc/150?u=george", alt: "George")
                  AvatarFallback { "GK" }
                end
                div do
                  p(class: "text-sm font-semibold") { "George Kettle" }
                  p(class: "text-xs text-muted-foreground") { "Creator of RubyUI" }
                end
              end
            end
            CardContent do
              p(class: "text-sm bg-muted p-3 rounded-lg") do
                "Hey! RubyUI is finally live. Let me know what you think of the new mosaic home page! 💎"
              end
            end
            CardFooter(class: "pt-0") do
              Input(placeholder: "Type a message...", class: "flex-1")
              Button(icon: true, variant: :ghost, class: "ml-2") do
                lucide_icon "send", class: "h-4 w-4"
              end
            end
          end
        end
      end
    end
  end

  private

  def team_member(name, handle, avatar_url)
    div(class: "flex items-center justify-between") do
      div(class: "flex items-center gap-4") do
        Avatar do
          AvatarImage(src: avatar_url, alt: name)
          AvatarFallback { name.split.map(&:first).join }
        end
        div do
          p(class: "text-sm font-medium leading-none") { name }
          p(class: "text-xs text-muted-foreground") { handle }
        end
      end
      Button(variant: :ghost, size: :sm) { "Edit" }
    end
  end

  def activity_item(title, time, status)
    div(class: "flex items-center gap-4") do
      div(class: [
        "h-2 w-2 rounded-full",
        (status == :success ? "bg-green-500" : (status == :warning ? "bg-amber-500" : "bg-blue-500"))
      ])
      div do
        p(class: "text-sm font-medium") { title }
        p(class: "text-xs text-muted-foreground") { time }
      end
    end
  end
end
