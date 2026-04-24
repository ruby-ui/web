# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePagination::PagyTest < ActiveSupport::TestCase
  PagyDouble = Data.define(:page, :pages, :count, :items)

  test "reads page, pages, count, items" do
    pagy = PagyDouble.new(page: 2, pages: 5, count: 47, items: 10)
    adapter = RubyUI::DataTablePagination::Pagy.new(pagy)
    assert_equal 2, adapter.current_page
    assert_equal 5, adapter.total_pages
    assert_equal 47, adapter.total_count
    assert_equal 10, adapter.per_page
  end
end
