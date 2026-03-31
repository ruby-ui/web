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
          "Build your compo­nent library."
        end
        p(class: "max-w-4xl text-base text-balance text-foreground sm:text-lg") do
          "Beautifully designed components that you can copy and paste into your apps. Accessible. Customizable. Open Source."
        end
        div(class: "space-x-4 mt-4") do
          Link(href: docs_introduction_path, variant: :primary, size: :lg) { "Documentation" }
          Link(href: docs_components_path, variant: :outline, size: :lg) { "View Components" }
        end
      end
    end

    # Features / Components Showcase
    section(class: "container space-y-6 py-8 md:py-12 lg:py-24 mx-auto max-w-5xl") do
      div(class: "mx-auto flex max-w-[58rem] flex-col items-center space-y-4 text-center") do
        h2(class: "scroll-m-24 text-5xl font-semibold tracking-tight") { "Features" }
        p(class: "max-w-[85%] leading-normal text-foreground sm:text-lg sm:leading-7") do
          "This library comes packed with all the concepts and tools you need to build out your application."
        end
      end

      # Features Grid
      div(class: "mx-auto grid justify-center gap-4 sm:grid-cols-2 md:max-w-[64rem] md:grid-cols-3 pt-8") do
        feature_card(title: "Built for Speed", description: "Dive into a world where your Rails UI development happens at light speed. Phlex is not just fast - it's blazing fast.")
        feature_card(title: "Minimal Dependencies", description: "Keep your app lean and mean. With RubyUI, we use custom built Stimulus.js controllers wherever possible.")
        feature_card(title: "Awesome UX", description: "Create an app experience your users will rave about. RubyUI ensures that your user's journey is memorable.")
        feature_card(title: "Completely Customisable", description: "Have full control over the design of all components. Built using Tailwind utilities.")
        feature_card(title: "Stay Organized", description: "Say goodbye to clutter. With Phlex, your UI components are not only organized, but also easy to manage.")
        feature_card(title: "Reuse with Ease", description: "Avoid the hassle of constantly reconstructing components. With Phlex, once built, use them seamlessly.")
      end

      # Video container
      div(class: "flex justify-center mt-8 mb-12 py-12") do
        iframe(width: "100%", height: "600", src: "https://www.youtube.com/embed/OQZam7rug00?si=JmZNzS5u194Q0AWQ", title: "YouTube video player", frameborder: "0", class: "rounded-xl border shadow-lg", allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share", allowfullscreen: true)
      end
    end
  end

  private

  def feature_card(title:, description:)
    div(class: "relative overflow-hidden rounded-lg border bg-background p-2") do
      div(class: "flex h-[140px] flex-col justify-between rounded-md p-6") do
        div(class: "space-y-2") do
          h3(class: "font-bold text-lg") { title }
          p(class: "text-base text-foreground leading-relaxed") { description }
        end
      end
    end
  end
end
