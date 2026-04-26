require "test_helper"

class RubyUI::DataTableFormTest < ActiveSupport::TestCase
  test "renders form with method=post and action" do
    out = render_component(RubyUI::DataTableForm.new(action: "/x"))
    assert_match(/<form[^>]*action="\/x"[^>]*method="post"|<form[^>]*method="post"[^>]*action="\/x"/, out)
  end

  test "renders hidden authenticity_token" do
    out = render_component(RubyUI::DataTableForm.new)
    assert_match(/<input[^>]*type="hidden"[^>]*name="authenticity_token"[^>]*value="[^"]+"/, out)
  end

  test "yields children" do
    out = render_component(RubyUI::DataTableForm.new) { "INNER" }
    assert_match(/INNER/, out)
  end

  test "renders form with id attribute when given" do
    out = render_component(RubyUI::DataTableForm.new(id: "my_form"))
    assert_match(/<form[^>]*id="my_form"/, out)
  end

  test "renders form with method=get when given" do
    out = render_component(RubyUI::DataTableForm.new(method: "get"))
    assert_match(/<form[^>]*method="get"/, out)
  end

  test "renders form with method=delete when given" do
    out = render_component(RubyUI::DataTableForm.new(method: "delete"))
    assert_match(/<form[^>]*method="delete"/, out)
  end
end
