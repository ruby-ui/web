# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSortHeadTest < ActiveSupport::TestCase
  test "renders a <th> with a sort link cycling nil -> asc" do
    out = RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {}).call
    assert_match(/<th/, out)
    assert_match(/href="\/x\?(sort=name&(amp;)?direction=asc|direction=asc&(amp;)?sort=name)"/, out)
    assert_match(/Name/, out)
  end

  test "current asc -> next href is desc" do
    out = RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "asc", path: "/x", query: {}).call
    assert_match(/direction=desc/, out)
  end

  test "current desc -> next href clears sort (no params)" do
    out = RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "desc", path: "/x", query: {}).call
    assert_match(/href="\/x"/, out)
  end

  test "preserves other query params" do
    out = RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {"search" => "alice"}).call
    assert_match(/search=alice/, out)
  end

  test "renames sort/direction params" do
    out = RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort_param: "sort_by", direction_param: "sort_dir", path: "/x", query: {}).call
    assert_match(/sort_by=name/, out)
    assert_match(/sort_dir=asc/, out)
  end

  test "custom page_param is dropped from next href when sorting" do
    out = RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", page_param: "p", path: "/x", query: {"p" => "3", "search" => "bob"}).call
    assert_no_match(/[?&]p=/, out)
    assert_match(/search=bob/, out)
  end
end
