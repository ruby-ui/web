require "test_helper"

class RubyUI::DataTableRowCheckboxTest < ActiveSupport::TestCase
  test "renders <input type=checkbox name=ids[] value=...>" do
    out = RubyUI::DataTableRowCheckbox.new(value: 42).call
    assert_match(/<input[^>]*type="checkbox"/, out)
    assert_match(/name="ids\[\]"/, out)
    assert_match(/value="42"/, out)
  end

  test "accepts custom name" do
    out = RubyUI::DataTableRowCheckbox.new(value: 1, name: "selected[]").call
    assert_match(/name="selected\[\]"/, out)
  end

  test "carries Stimulus target + action" do
    out = RubyUI::DataTableRowCheckbox.new(value: 1).call
    assert_match(/data-ruby-ui--data-table-target="rowCheckbox"/, out)
    assert_match(/data-action="[^"]*change->ruby-ui--data-table#toggleRow/, out)
  end

  test "ARIA label contains the value" do
    out = RubyUI::DataTableRowCheckbox.new(value: 7).call
    assert_match(/aria-label="Select row 7"/, out)
  end
end
