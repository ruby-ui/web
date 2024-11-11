# frozen_string_literal: true

class Shared::Sidebar < ApplicationComponent
  def view_template
    aside(class: "fixed top-14 z-30 -ml-2 hidden h-[calc(100vh-3.5rem)] w-full shrink-0 md:sticky md:block") do
      div(class: "relative overflow-hidden h-full py-6 pl-8 pr-6 lg:py-8", style: "position:relative;--radix-scroll-area-corner-width:0px;--radix-scroll-area-corner-height:0px") do
        div(id: "sidebar-menu", class: "h-full w-full rounded-[inherit]", style: "overflow: hidden scroll;") do
          render Shared::Menu.new
        end
      end
    end

    script do
      safe <<-JS
        window.addEventListener("turbo:before-visit", () => {
          localStorage.setItem("menuScrollPositon", document.getElementById("sidebar-menu").scrollTop);
        });

        window.addEventListener("turbo:load", () => {
          document.getElementById("sidebar-menu").scrollTop = localStorage.getItem("menuScrollPositon") || 0;
        });
      JS
    end
  end
end
