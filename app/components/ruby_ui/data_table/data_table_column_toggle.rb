# frozen_string_literal: true

module RubyUI
  class DataTableColumnToggle < Base
    def initialize(label: "Columns", **attrs)
      @label = label
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        button(
          type: "button",
          class: "inline-flex items-center justify-center gap-1 rounded-md border border-input bg-background px-3 h-8 text-sm font-medium ring-offset-background hover:bg-accent hover:text-accent-foreground",
          data: {
            action: "click->ruby-ui--data-table#toggleColumnMenu",
            ruby_ui__data_table_target: "columnToggleTrigger"
          }
        ) do
          plain @label
          svg(
            xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            class: "ml-1 h-3 w-3"
          ) { |s| s.path(d: "m6 9 6 6 6-6") }
        end

        # Dropdown populated by Stimulus via table.getAllLeafColumns()
        div(
          class: "hidden absolute mt-2 w-56 rounded-md border bg-popover p-1 text-popover-foreground shadow-md z-50",
          data: {ruby_ui__data_table_target: "columnMenu"}
        )
      end
    end

    private

    def default_attrs
      {class: "relative"}
    end
  end
end
