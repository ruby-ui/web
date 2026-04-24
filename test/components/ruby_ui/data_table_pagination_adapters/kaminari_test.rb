# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePaginationAdapters::KaminariTest < ActiveSupport::TestCase
  CollectionDouble = Data.define(:current_page, :total_pages, :total_count, :limit_value)

  test "reads current_page, total_pages, total_count, limit_value" do
    coll = CollectionDouble.new(current_page: 3, total_pages: 7, total_count: 61, limit_value: 10)
    adapter = RubyUI::DataTablePaginationAdapters::Kaminari.new(coll)
    assert_equal 3, adapter.current_page
    assert_equal 7, adapter.total_pages
    assert_equal 61, adapter.total_count
    assert_equal 10, adapter.per_page
  end
end
