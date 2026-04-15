# frozen_string_literal: true

module RubyUI
  # Boolean rendered as ✓ / —.
  class DataTableCellBoolean < Base
    def initialize(key:, **attrs)
      @key = key
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_format: "boolean"
      }) do
        span(data: {field: true})
      end
    end
  end
end
