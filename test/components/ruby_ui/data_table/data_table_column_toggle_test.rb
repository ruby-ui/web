require "test_helper"

class RubyUI::DataTableColumnToggleTest < ActiveSupport::TestCase
  test "renders dropdown with checkbox per column" do
    out = RubyUI::DataTableColumnToggle.new(columns: [
      {key: :email, label: "Email"},
      {key: :salary, label: "Salary"}
    ]).call
    assert_match(/Columns/, out)
    assert_match(/data-controller="[^"]*ruby-ui--data-table-column-visibility/, out)
    assert_match(/data-column-key="email"/, out)
    assert_match(/data-column-key="salary"/, out)
    assert_match(/Email/, out)
    assert_match(/Salary/, out)
  end
end
