require "test_helper"

class RubyUI::DataTableBulkActionsTest < ActiveSupport::TestCase
  test "starts hidden with bulkActions target + renders children" do
    out = RubyUI::DataTableBulkActions.new.call { "BUTTONS" }
    assert_match(/class="[^"]*hidden[^"]*"/, out)
    assert_match(/data-ruby-ui--data-table-target="bulkActions"/, out)
    assert_match(/BUTTONS/, out)
  end
end
