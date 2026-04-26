# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSearchTest < ActiveSupport::TestCase
  test "renders GET form with search input" do
    out = RubyUI::DataTableSearch.new(path: "/x", value: "alice", name: "search").call
    assert_match(/<form[^>]*method="get"[^>]*action="\/x"/, out)
    assert_match(/name="search"/, out)
    assert_match(/value="alice"/, out)
  end

  test "renames param via name:" do
    out = RubyUI::DataTableSearch.new(path: "/x", name: "q").call
    assert_match(/name="q"/, out)
  end

  test "emits data-turbo-frame when frame_id given" do
    out = RubyUI::DataTableSearch.new(path: "/x", frame_id: "employees").call
    assert_match(/data-turbo-frame="employees"/, out)
  end

  test "emits debounce controller + delay value + action by default" do
    out = RubyUI::DataTableSearch.new(path: "/x").call
    assert_match(/data-controller="ruby-ui--data-table-search"/, out)
    assert_match(/data-ruby-ui--data-table-search-delay-value="300"/, out)
    assert_match(/data-action="input->ruby-ui--data-table-search#submit"/, out)
  end

  test "debounce: 500 sets custom delay" do
    out = RubyUI::DataTableSearch.new(path: "/x", debounce: 500).call
    assert_match(/data-ruby-ui--data-table-search-delay-value="500"/, out)
  end

  test "debounce: false disables auto-submit" do
    out = RubyUI::DataTableSearch.new(path: "/x", debounce: false).call
    assert_no_match(/data-controller="ruby-ui--data-table-search"/, out)
    assert_no_match(/data-ruby-ui--data-table-search-delay-value/, out)
  end

  test "debounce: 0 disables auto-submit" do
    out = RubyUI::DataTableSearch.new(path: "/x", debounce: 0).call
    assert_no_match(/data-controller="ruby-ui--data-table-search"/, out)
  end

  test "preserved_params emits hidden inputs for each key" do
    out = RubyUI::DataTableSearch.new(path: "/x", name: "search", preserved_params: {"sort" => "name", "direction" => "asc", "per_page" => "10"}).call
    assert_match(/<input[^>]*type="hidden"[^>]*name="sort"[^>]*value="name"/, out)
    assert_match(/<input[^>]*type="hidden"[^>]*name="direction"[^>]*value="asc"/, out)
    assert_match(/<input[^>]*type="hidden"[^>]*name="per_page"[^>]*value="10"/, out)
  end

  test "preserved_params skips blank values" do
    out = RubyUI::DataTableSearch.new(path: "/x", preserved_params: {"sort" => "", "direction" => nil}).call
    assert_no_match(/name="sort"/, out)
    assert_no_match(/name="direction"/, out)
  end

  test "preserved_params skips the search param itself" do
    out = RubyUI::DataTableSearch.new(path: "/x", name: "q", preserved_params: {"q" => "alice", "sort" => "name"}).call
    assert_no_match(/<input[^>]*type="hidden"[^>]*name="q"/, out)
    assert_match(/name="sort"/, out)
  end
end
