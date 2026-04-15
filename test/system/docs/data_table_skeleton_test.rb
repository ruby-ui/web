require "application_system_test_case"

class Docs::DataTableSkeletonTest < ApplicationSystemTestCase
  test "renders rows from data attribute via TanStack" do
    visit "/docs/data_table"

    # Wait for Stimulus to connect and TanStack to render rows
    assert_selector "[data-controller='ruby-ui--data-table'] tbody tr", minimum: 3

    # First row should contain the seed data
    within("[data-controller='ruby-ui--data-table'] tbody tr:first-child") do
      assert_text "Alice Johnson"
      assert_text "alice@example.com"
    end

    # Headers should come from columns config
    within("[data-controller='ruby-ui--data-table'] thead") do
      assert_text "Name"
      assert_text "Email"
    end
  end
end
