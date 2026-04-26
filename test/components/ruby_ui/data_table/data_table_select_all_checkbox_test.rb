require "test_helper"

class RubyUI::DataTableSelectAllCheckboxTest < ActiveSupport::TestCase
  test "carries selectAll target + toggleAll action + aria-label" do
    out = RubyUI::DataTableSelectAllCheckbox.new.call
    assert_match(/<input[^>]*type="checkbox"/, out)
    assert_match(/data-ruby-ui--data-table-target="selectAll"/, out)
    assert_match(/data-action="[^"]*change->ruby-ui--data-table#toggleAll/, out)
    assert_match(/aria-label="Select all"/, out)
  end
end
