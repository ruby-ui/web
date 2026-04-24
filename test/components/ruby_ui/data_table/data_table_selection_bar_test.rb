require "test_helper"

class RubyUI::DataTableSelectionBarTest < ActiveSupport::TestCase
  test "renders with selectionBar target + flex layout + children" do
    out = RubyUI::DataTableSelectionBar.new.call { "INNER" }
    assert_match(/data-ruby-ui--data-table-target="selectionBar"/, out)
    assert_match(/class="[^"]*flex[^"]*"/, out)
    assert_match(/INNER/, out)
  end
end
