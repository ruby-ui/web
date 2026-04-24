require "test_helper"

class RubyUI::DataTablePagination::ManualTest < ActiveSupport::TestCase
  test "computes total_pages from total_count and per_page" do
    adapter = RubyUI::DataTablePagination::Manual.new(page: 2, per_page: 10, total_count: 25)
    assert_equal 2, adapter.current_page
    assert_equal 10, adapter.per_page
    assert_equal 25, adapter.total_count
    assert_equal 3, adapter.total_pages
  end

  test "total_pages is at least 1 for empty total" do
    adapter = RubyUI::DataTablePagination::Manual.new(page: 1, per_page: 10, total_count: 0)
    assert_equal 1, adapter.total_pages
  end

  test "coerces integer inputs" do
    adapter = RubyUI::DataTablePagination::Manual.new(page: "3", per_page: "5", total_count: "12")
    assert_equal 3, adapter.current_page
    assert_equal 3, adapter.total_pages
  end
end
