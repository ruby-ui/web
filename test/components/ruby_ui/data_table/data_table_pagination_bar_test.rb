require "test_helper"

class RubyUI::DataTablePaginationBarTest < ActiveSupport::TestCase
  test "renders flex justify-between layout + children" do
    out = RubyUI::DataTablePaginationBar.new.call { "INNER" }
    assert_match(/class="[^"]*flex[^"]*"/, out)
    assert_match(/class="[^"]*justify-between[^"]*"/, out)
    assert_match(/INNER/, out)
  end
end
