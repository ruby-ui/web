# frozen_string_literal: true

module RubyUI
  # Locale-formatted date via Date.toLocaleDateString.
  class DataTableCellDate < Base
    def initialize(key:, locale: "en-US", **attrs)
      @key = key
      @locale = locale
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_format: "date",
        cell_locale: @locale
      }) do
        span(data: {field: true})
      end
    end
  end
end
