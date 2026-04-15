# frozen_string_literal: true

module RubyUI
  # Truncated text with full value on hover via title attribute.
  class DataTableCellTruncate < Base
    def initialize(key:, max: 40, **attrs)
      @key = key
      @max = max
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_format: "truncate",
        cell_max: @max
      }) do
        span(data: {field: true, apply_title: true})
      end
    end
  end
end
