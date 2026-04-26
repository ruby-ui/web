require "test_helper"

class RubyUI::DataTablePerPageSelectTest < ActiveSupport::TestCase
  test "renders GET form with select and options" do
    out = RubyUI::DataTablePerPageSelect.new(path: "/x", value: 25, options: [5, 10, 25, 50]).call
    assert_match(/<form[^>]*(method="get"[^>]*action="\/x"|action="\/x"[^>]*method="get")/, out)
    assert_match(/name="per_page"/, out)
    assert_match(/value="25"[^>]*selected|selected[^>]*value="25"/, out)
    assert_match(/onchange="this\.form\.requestSubmit\(\)"/, out)
  end

  test "renames param via name:" do
    out = RubyUI::DataTablePerPageSelect.new(path: "/x", name: "size").call
    assert_match(/name="size"/, out)
  end

  test "includes given options" do
    out = RubyUI::DataTablePerPageSelect.new(path: "/x", options: [5, 10, 25]).call
    assert_match(/<option[^>]*value="5"/, out)
    assert_match(/<option[^>]*value="10"/, out)
    assert_match(/<option[^>]*value="25"/, out)
  end
end
