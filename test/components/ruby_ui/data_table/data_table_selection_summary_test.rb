require "test_helper"

class RubyUI::DataTableSelectionSummaryTest < ActiveSupport::TestCase
  test "renders '0 of N row(s) selected.' with target" do
    out = RubyUI::DataTableSelectionSummary.new(total_on_page: 10).call
    assert_match(/0 of 10 row\(s\) selected\./, out)
    assert_match(/data-ruby-ui--data-table-target="selectionSummary"/, out)
  end
end
