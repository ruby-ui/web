# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableTest < ActiveSupport::TestCase
  test "renders a turbo-frame with given id" do
    output = RubyUI::DataTable.new(id: "employees").call
    assert_match %r{<turbo-frame[^>]*id="employees"[^>]*target="_top"}, output
  end

  test "sets data-controller on inner form" do
    output = RubyUI::DataTable.new(id: "x").call
    assert_match(/data-controller="ruby-ui--data-table"/, output)
  end

  test "renders children inside form" do
    output = RubyUI::DataTable.new(id: "x").call { "INNER" }
    assert_match(/INNER/, output)
    assert_match(/<form/, output)
  end
end
