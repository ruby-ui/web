# frozen_string_literal: true

module RubyUI
  class DataTableAvoColumnToggle < Base
    # @param columns [Array<Hash>] [{key:, label:}] of togglable columns
    def initialize(columns:, **attrs)
      @columns = columns
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        button(
          type: "button",
          class: "inline-flex items-center justify-center gap-2 rounded-md border border-input bg-background px-3 h-9 text-sm font-medium hover:bg-accent hover:text-accent-foreground",
          data: {action: "click->ruby-ui--data-table-avo#toggleColumnsMenu"}
        ) do
          plain "Columns"
          svg(
            xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            class: "w-4 h-4"
          ) { |s| s.path(d: "m6 9 6 6 6-6") }
        end

        div(
          class: "hidden absolute right-0 mt-1 min-w-[8rem] rounded-md border bg-popover p-1 shadow-md z-50",
          data: {ruby_ui__data_table_avo_target: "columnsMenu"}
        ) do
          @columns.each do |col|
            label(class: "flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer hover:bg-accent") do
              input(
                type: "checkbox",
                checked: true,
                class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                data: {
                  column_key: col[:key].to_s,
                  action: "change->ruby-ui--data-table-avo#toggleColumnVisibility"
                }
              )
              span { plain col[:label] }
            end
          end
        end
      end
    end

    private

    def default_attrs
      {class: "relative"}
    end
  end
end
