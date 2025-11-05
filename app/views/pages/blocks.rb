# frozen_string_literal: true

class Views::Pages::Blocks < Views::Pages::Base
  def layout = Views::Layouts::PagesLayout

  def page_title = "Building Blocks for the Web"

  def view_template
    div(class: "mx-auto w-full max-w-5xl md:max-w-6xl px-4 py-14 md:py-16 space-y-10") do
      div(class: "text-center space-y-4") do
        Components.Heading(level: 1, as: "h1", class: "text-4xl md:text-6xl font-bold tracking-tight") { "Building Blocks for the Web" }
        p(class: "text-muted-foreground text-base md:text-lg") { "Clean, modern building blocks. Copy and paste into your apps." }
        p(class: "text-muted-foreground text-base md:text-lg") { "Works with all React frameworks. Open Source. Free forever." }
        div(class: "flex flex-col sm:flex-row items-center justify-center gap-3 pt-2") do
          Link(variant: :primary, href: blocks_path, class: "px-5") { "Browse Blocks" }
          Link(variant: :ghost, href: docs_introduction_path, class: "px-5") { "Add a block" }
        end
      end

      # render Components::BlockViewer.new
      # render ComponentPreview.new(title: "Example", context: self, type: :block, content: Blocks::Sidebar02)
      # <BlockDisplay name={name} key={name} styleName={activeStyle.name} />
      render BlockDisplay.new(description: "A dashboard with sidebar, charts and data table", content: Blocks::Sidebar02)
      # render Docs::VisualCodeExample.new(
      #   title: "Example",
      #   context: self,
      #   type: :block,
      #   content: Blocks::Sidebar02,
      # )
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

  def external_icon_link
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-external-link-icon lucide-external-link size-3"
    ) do |s|
      s.path(d: "M15 3h6v6")
      s.path(d: "M10 14 21 3")
      s.path(d: "M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6")
    end
  end

  def info_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm8.706-1.442c1.146-.573 2.437.463 2.126 1.706l-.709 2.836.042-.02a.75.75 0 01.67 1.34l-.04.022c-1.147.573-2.438-.463-2.127-1.706l.71-2.836-.042.02a.75.75 0 11-.671-1.34l.041-.022zM12 9a.75.75 0 100-1.5.75.75 0 000 1.5z",
        clip_rule: "evenodd"
      )
    end
  end
end
