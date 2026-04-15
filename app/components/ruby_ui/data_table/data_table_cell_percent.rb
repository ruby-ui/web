# frozen_string_literal: true

module RubyUI
  # Percentage via browser Intl.NumberFormat — accepts raw fractions (0.25 → 25%).
  class DataTableCellPercent < Base
    def initialize(key:, digits: 0, locale: "en-US", **attrs)
      @key = key
      @digits = digits
      @locale = locale
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_format: "percent",
        cell_digits: @digits,
        cell_locale: @locale
      }) do
        span(data: {field: true})
      end
    end
  end
end
