# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    # @param data [Array<Hash>] current page rows
    # @param columns [Array<Hash>] [{ key:, header:, type: (optional) }]
    # @param src [String, nil] URL for JSON fetches on state change
    # @param row_count [Integer] total rows across all pages
    # @param page [Integer] current page, 1-based (converted to 0-based pageIndex for TanStack)
    # @param per_page [Integer] rows per page
    def initialize(data: [], columns: [], src: nil, row_count: 0, page: 1, per_page: 10, **attrs)
      @data = data
      @columns = columns
      @src = src
      @row_count = row_count
      @page = page
      @per_page = per_page
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "w-full space-y-4",
        data: {
          controller: "ruby-ui--data-table",
          ruby_ui__data_table_src_value: @src.to_s,
          ruby_ui__data_table_data_value: @data.to_json,
          ruby_ui__data_table_columns_value: @columns.to_json,
          ruby_ui__data_table_row_count_value: @row_count,
          ruby_ui__data_table_pagination_value: {pageIndex: @page - 1, pageSize: @per_page}.to_json
        }
      }
    end
  end
end
