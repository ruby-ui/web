# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    # @param data [Array<Hash>] current page rows
    # @param columns [Array<Hash>] [{ key:, header:, type: (optional), colors: (optional) }]
    # @param src [String, nil] URL for JSON fetches
    # @param row_count [Integer] total rows across all pages
    # @param page [Integer] current page, 1-based
    # @param per_page [Integer] rows per page
    # @param sort [String, nil] sorted column key
    # @param direction [String, nil] "asc" or "desc"
    # @param search [String, nil] initial search query
    # @param selectable [Boolean] enable row selection with checkboxes
    def initialize(data: [], columns: [], src: nil, row_count: 0,
      page: 1, per_page: 10, sort: nil, direction: nil, search: nil,
      selectable: false, **attrs)
      @data = data
      @columns = columns
      @src = src
      @row_count = row_count
      @page = page
      @per_page = per_page
      @sort = sort
      @direction = direction
      @search = search
      @selectable = selectable
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      sorting = @sort.present? ? [{id: @sort, desc: @direction == "desc"}] : []
      {
        class: "w-full space-y-4",
        data: {
          controller: "ruby-ui--data-table",
          ruby_ui__data_table_src_value: @src.to_s,
          ruby_ui__data_table_data_value: @data.to_json,
          ruby_ui__data_table_columns_value: @columns.to_json,
          ruby_ui__data_table_row_count_value: @row_count,
          ruby_ui__data_table_pagination_value: {pageIndex: @page - 1, pageSize: @per_page}.to_json,
          ruby_ui__data_table_sorting_value: sorting.to_json,
          ruby_ui__data_table_search_value: @search.to_s,
          ruby_ui__data_table_selectable_value: @selectable
        }
      }
    end
  end
end
