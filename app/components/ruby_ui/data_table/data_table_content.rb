# frozen_string_literal: true

module RubyUI
  class DataTableContent < Base
    def view_template
      div(**attrs) do
        table(class: "w-full caption-bottom text-sm") do
          thead(class: "[&_tr]:border-b", data: {ruby_ui__data_table_target: "thead"})
          tbody(class: "[&_tr:last-child]:border-0", data: {ruby_ui__data_table_target: "tbody"})
        end

        # Icon templates — rendered by Phlex, cloned by Stimulus. No SVG in JS.
        template(data: {ruby_ui__data_table_target: "tplSortAsc"}) do
          svg(
            xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            class: "ml-1 inline-block w-3 h-3"
          ) { |s| s.path(d: "m18 15-6-6-6 6") }
        end

        template(data: {ruby_ui__data_table_target: "tplSortDesc"}) do
          svg(
            xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            class: "ml-1 inline-block w-3 h-3"
          ) { |s| s.path(d: "m6 9 6 6 6-6") }
        end

        template(data: {ruby_ui__data_table_target: "tplSortNone"}) do
          svg(
            xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24",
            fill: "none", stroke: "currentColor", stroke_width: "2",
            stroke_linecap: "round", stroke_linejoin: "round",
            class: "ml-1 inline-block w-3 h-3 opacity-30"
          ) { |s| s.path(d: "m7 15 5 5 5-5M7 9l5-5 5 5") }
        end

        template(data: {ruby_ui__data_table_target: "tplCheckbox"}) do
          input(
            type: "checkbox",
            class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer"
          )
        end
      end
    end

    private

    def default_attrs
      {class: "rounded-md border"}
    end
  end
end
