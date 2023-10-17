# frozen_string_literal: true

class Docs::PopoverView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Popover" }
        render Typography::P.new { "Displays rich content in a portal, triggered by a button." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render Popover.new do
          render PopoverTrigger.new do
            render Button.new(variant: :outline) { "Open Popover" }
          end
          popover_content
        end
      end

      render Docs::VisualCodeExample.new(title: "Placement") do
        positions = %w[top right left bottom]
        
        div(class: 'grid grid-cols-3 gap-4') do
          positions.each do |position|
            position_variants = [
              position,
              "#{position}-start",
              "#{position}-end"
            ]

            position_variants.each do |position_variant|
              render Popover.new(options: { placement: position_variant }) do
                render PopoverTrigger.new do
                  render Button.new(variant: :outline, class: 'w-full justify-center') { position_variant }
                end
                popover_content
              end
            end
          end
        end
      end

      render Docs::VisualCodeExample.new(title: "Trigger") do
        render Popover.new(options: { trigger: 'click' }) do
          render PopoverTrigger.new do
            render Button.new(variant: :outline) { "Click" }
          end
          popover_content
        end
      end
    end
  end

  def popover_content
    render PopoverContent.new(class: 'w-40') do
      render Link.new(href: "#", variant: :ghost, class: 'block w-full justify-start pl-2') do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: "w-4 h-4 mr-2"
        ) do |s|
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d:
              "M17.982 18.725A7.488 7.488 0 0012 15.75a7.488 7.488 0 00-5.982 2.975m11.963 0a9 9 0 10-11.963 0m11.963 0A8.966 8.966 0 0112 21a8.966 8.966 0 01-5.982-2.275M15 9.75a3 3 0 11-6 0 3 3 0 016 0z"
          )
        end
        plain "Profile"
      end
      render Link.new(href: "#", variant: :ghost, class: 'block w-full justify-start pl-2') do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: "w-4 h-4 mr-2"
        ) do |s|
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d:
              "M10.343 3.94c.09-.542.56-.94 1.11-.94h1.093c.55 0 1.02.398 1.11.94l.149.894c.07.424.384.764.78.93.398.164.855.142 1.205-.108l.737-.527a1.125 1.125 0 011.45.12l.773.774c.39.389.44 1.002.12 1.45l-.527.737c-.25.35-.272.806-.107 1.204.165.397.505.71.93.78l.893.15c.543.09.94.56.94 1.109v1.094c0 .55-.397 1.02-.94 1.11l-.893.149c-.425.07-.765.383-.93.78-.165.398-.143.854.107 1.204l.527.738c.32.447.269 1.06-.12 1.45l-.774.773a1.125 1.125 0 01-1.449.12l-.738-.527c-.35-.25-.806-.272-1.203-.107-.397.165-.71.505-.781.929l-.149.894c-.09.542-.56.94-1.11.94h-1.094c-.55 0-1.019-.398-1.11-.94l-.148-.894c-.071-.424-.384-.764-.781-.93-.398-.164-.854-.142-1.204.108l-.738.527c-.447.32-1.06.269-1.45-.12l-.773-.774a1.125 1.125 0 01-.12-1.45l.527-.737c.25-.35.273-.806.108-1.204-.165-.397-.505-.71-.93-.78l-.894-.15c-.542-.09-.94-.56-.94-1.109v-1.094c0-.55.398-1.02.94-1.11l.894-.149c.424-.07.765-.383.93-.78.165-.398.143-.854-.107-1.204l-.527-.738a1.125 1.125 0 01.12-1.45l.773-.773a1.125 1.125 0 011.45-.12l.737.527c.35.25.807.272 1.204.107.397-.165.71-.505.78-.929l.15-.894z"
          )
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z"
          )
        end
        plain "Settings"
      end
      render Link.new(href: "#", variant: :ghost, class: 'block w-full justify-start pl-2') do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: "w-4 h-4 mr-2"
        ) do |s|
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d:
              "M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9"
          )
        end
        plain "Logout"
      end
    end
  end
end