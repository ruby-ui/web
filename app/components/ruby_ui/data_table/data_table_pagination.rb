# frozen_string_literal: true

module RubyUI
  class DataTablePagination < Base
    def initialize(current_page:, total_pages:, **attrs)
      @current_page = current_page
      @total_pages = total_pages
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        div(class: "flex items-center justify-between px-2") do
          div(
            class: "flex-1 text-sm text-muted-foreground",
            data: {ruby_ui__data_table_target: "pageIndicator"}
          ) do
            plain "Page #{@current_page} of #{@total_pages}"
          end
          div(class: "flex items-center space-x-2") do
            nav_button(
              direction: "previous",
              disabled: @current_page <= 1,
              action: "click->ruby-ui--data-table#previousPage",
              target: "prevButton",
              icon_path: "m15 18-6-6 6-6"
            )
            nav_button(
              direction: "next",
              disabled: @current_page >= @total_pages,
              action: "click->ruby-ui--data-table#nextPage",
              target: "nextButton",
              icon_path: "m9 18 6-6-6-6"
            )
          end
        end
      end
    end

    private

    def nav_button(direction:, disabled:, action:, target:, icon_path:)
      button(
        type: "button",
        class: "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors hover:bg-accent hover:text-accent-foreground h-8 w-8 p-0 #{disabled ? "opacity-50 pointer-events-none" : nil}",
        disabled: disabled,
        aria_label: direction,
        data: {
          action: action,
          ruby_ui__data_table_target: target
        }
      ) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "16", height: "16", viewBox: "0 0 24 24",
          fill: "none", stroke: "currentColor",
          stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round"
        ) { |s| s.path(d: icon_path) }
      end
    end

    def default_attrs
      {class: "flex items-center justify-end py-4"}
    end
  end
end
