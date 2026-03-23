# frozen_string_literal: true

module RubyUI
  class DataTableSortableHeader < Base
    def initialize(column:, label: nil, direction: nil, **attrs)
      @column = column
      @label = label || column.to_s.tr("_", " ").capitalize
      @direction = direction # nil, "asc", or "desc"
      super(**attrs)
    end

    def view_template(&block)
      th(**attrs) do
        button(
          type: "button",
          class: "inline-flex items-center gap-1 hover:text-foreground",
          data: {
            action: "click->ruby-ui--data-table#sort",
            ruby_ui__data_table_column_param: @column,
            ruby_ui__data_table_direction_param: next_direction
          }
        ) do
          if block
            yield
          else
            plain @label
          end
          render_sort_icon
        end
      end
    end

    private

    def next_direction
      case @direction
      when "asc" then "desc"
      when "desc" then ""
      else "asc"
      end
    end

    def render_sort_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        width: "14", height: "14",
        viewBox: "0 0 24 24",
        fill: "none", stroke: "currentColor",
        stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
        class: "ml-1 #{@direction ? "" : "text-muted-foreground"}"
      ) do |s|
        if @direction == "asc"
          s.path(d: "m18 15-6-6-6 6")
        elsif @direction == "desc"
          s.path(d: "m6 9 6 6 6-6")
        else
          s.path(d: "m7 15 5 5 5-5")
          s.path(d: "m7 9 5-5 5 5")
        end
      end
    end

    def default_attrs
      {
        class: "h-10 px-2 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0"
      }
    end
  end
end
