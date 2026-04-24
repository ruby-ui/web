require "test_helper"

class RubyUI::DataTableFormTest < ActiveSupport::TestCase
  test "renders form with method=post and action" do
    out = RubyUI::DataTableForm.new(action: "/x").call
    assert_match(/<form[^>]*action="\/x"[^>]*method="post"|<form[^>]*method="post"[^>]*action="\/x"/, out)
  end

  test "renders hidden authenticity_token" do
    out = RubyUI::DataTableForm.new.call
    assert_match(/<input[^>]*type="hidden"[^>]*name="authenticity_token"[^>]*value="[^"]+"/, out)
  end

  test "yields children" do
    out = RubyUI::DataTableForm.new.call { "INNER" }
    assert_match(/INNER/, out)
  end
end
