# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    # @param data [Array<Hash>] current page rows (each row is a hash keyed by column key)
    # @param columns [Array<Hash>] column definitions: [{ key: "name", header: "Name" }, ...]
    # @param src [String, nil] URL for JSON fetches on state change (unused in skeleton; reserved for Plan 02)
    # @param row_count [Integer] total rows across all pages (unused in skeleton; reserved for Plan 02)
    def initialize(data: [], columns: [], src: nil, row_count: 0, **attrs)
      @data = data
      @columns = columns
      @src = src
      @row_count = row_count
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
          ruby_ui__data_table_row_count_value: @row_count
        }
      }
    end
  end
end
