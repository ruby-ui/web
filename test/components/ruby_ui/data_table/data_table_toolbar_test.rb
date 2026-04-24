require "test_helper"

class RubyUI::DataTableToolbarTest < ActiveSupport::TestCase
  test "renders div with flex layout and children" do
    out = RubyUI::DataTableToolbar.new.call { "INNER" }
    assert_match(/<div[^>]*class="[^"]*flex[^"]*"/, out)
    assert_match(/INNER/, out)
  end
end
