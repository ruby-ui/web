# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSearchTest < ActiveSupport::TestCase
  test "renders GET form with search input" do
    out = RubyUI::DataTableSearch.new(path: "/x", value: "alice", name: "search").call
    assert_match(/<form[^>]*method="get"[^>]*action="\/x"/, out)
    assert_match(/<input[^>]*name="search"[^>]*value="alice"/, out)
  end

  test "renames param via name:" do
    out = RubyUI::DataTableSearch.new(path: "/x", name: "q").call
    assert_match(/name="q"/, out)
  end

  test "emits data-turbo-frame when frame_id given" do
    out = RubyUI::DataTableSearch.new(path: "/x", frame_id: "employees").call
    assert_match(/data-turbo-frame="employees"/, out)
  end
end
