require "test_helper"

class RubyUI::DataTableExpandToggleTest < ActiveSupport::TestCase
  test "renders a button with aria attributes + controller" do
    out = RubyUI::DataTableExpandToggle.new(controls: "emp-1-detail").call
    assert_match(/<button[^>]*type="button"/, out)
    assert_match(/aria-expanded="false"/, out)
    assert_match(/aria-controls="emp-1-detail"/, out)
    assert_match(/aria-label="Toggle row details"/, out)
    assert_match(/data-controller="[^"]*ruby-ui--data-table-row-expand/, out)
    assert_match(/data-action="[^"]*click->ruby-ui--data-table-row-expand#toggle/, out)
  end

  test "accepts custom label + initial expanded state" do
    out = RubyUI::DataTableExpandToggle.new(controls: "x", expanded: true, label: "Toggle").call
    assert_match(/aria-expanded="true"/, out)
    assert_match(/aria-label="Toggle"/, out)
  end
end
