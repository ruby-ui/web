require "test_helper"

class RubyUI::DataTablePaginationTest < ActiveSupport::TestCase
  test "accepts manual keyword shortcut" do
    out = RubyUI::DataTablePagination.new(page: 2, per_page: 10, total_count: 25, path: "/x", query: {}).call
    assert_match(/href="\/x\?page=1"/, out)  # Previous
    assert_match(/href="\/x\?page=3"/, out)  # next
  end

  test "accepts pagy keyword shortcut (duck-typed double)" do
    pagy_double = Data.define(:page, :pages, :count, :items).new(page: 1, pages: 2, count: 15, items: 10)
    out = RubyUI::DataTablePagination.new(pagy: pagy_double, path: "/x", query: {}).call
    assert_match(/href="\/x\?page=2"/, out)
  end

  test "with: accepts custom adapter" do
    custom = Data.define(:current_page, :total_pages, :total_count, :per_page).new(1, 3, 20, 10)
    out = RubyUI::DataTablePagination.new(with: custom, path: "/x", query: {}).call
    assert_match(/href="\/x\?page=2"/, out)
  end

  test "renames page param" do
    out = RubyUI::DataTablePagination.new(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}, page_param: "p").call
    assert_match(/p=2/, out)
  end

  test "raises when no adapter and no manual args" do
    assert_raises(ArgumentError) { RubyUI::DataTablePagination.new(path: "/x", query: {}) }
  end

  test "window: kwarg widens the numbered page range" do
    # 20 pages, on page 10, window:1 → [1, :gap, 9, 10, 11, :gap, 20]
    # window:2 → [1, :gap, 8, 9, 10, 11, 12, :gap, 20]
    out_narrow = RubyUI::DataTablePagination.new(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 1).call
    out_wide   = RubyUI::DataTablePagination.new(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 2).call
    assert_no_match(/page=8/, out_narrow)
    assert_match(/page=8/, out_wide)
  end
end
