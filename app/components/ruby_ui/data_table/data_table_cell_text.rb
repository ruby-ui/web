# frozen_string_literal: true

module RubyUI
  # Plain text cell. HTML-escaped value.
  # Also the fallback rendering when no cell component is declared for a column.
  class DataTableCellText < Base
    def initialize(key:, class: nil, **attrs)
      @key = key
      @class = binding.local_variable_get(:class)
      super(**attrs)
    end

    def view_template
      template(data: {ruby_ui__data_table_target: "tplCell_#{@key}"}) do
        span(class: @class, data: {field: true})
      end
    end
  end
end
