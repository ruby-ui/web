# frozen_string_literal: true

require "test_helper"

class Docs::DataTableSelectionTest < ActionDispatch::IntegrationTest
  test "data_table page renders with selectable value when selectable" do
    get docs_data_table_path
    assert_response :success
    # The demo page now has a selectable example
    assert_match "data-ruby-ui--data-table-selectable-value", response.body
  end

  test "DataTableBulkActions renders with correct target" do
    html = RubyUI::DataTableBulkActions.new.call
    assert_match "data-ruby-ui--data-table-target=\"bulkActions\"", html
  end
end
