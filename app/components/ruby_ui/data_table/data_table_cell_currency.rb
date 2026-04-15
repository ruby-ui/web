# frozen_string_literal: true

module RubyUI
  # Currency via browser Intl.NumberFormat.
  class DataTableCellCurrency < Base
    def initialize(key:, currency: "USD", digits: 0, locale: "en-US", **attrs)
      @key = key
      @currency = currency
      @digits = digits
      @locale = locale
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_format: "currency",
        cell_currency: @currency,
        cell_digits: @digits,
        cell_locale: @locale
      }) do
        span(data: {field: true})
      end
    end
  end
end
