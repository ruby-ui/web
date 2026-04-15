# frozen_string_literal: true

module RubyUI
  # Thousand-separated integer via browser Intl.NumberFormat.
  class DataTableCellNumber < Base
    def initialize(key:, locale: "en-US", **attrs)
      @key = key
      @locale = locale
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_format: "number",
        cell_locale: @locale
      }) do
        span(data: {field: true})
      end
    end
  end
end
