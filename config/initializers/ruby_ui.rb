# frozen_string_literal: true

module RubyUI
  extend Phlex::Kit
end

# Allow using RubyUI instead RubyUi
Rails.autoloaders.main.inflector.inflect(
  "ruby_ui" => "RubyUI"
)

# Allow using RubyUI::ComponentName instead Components::RubyUI::ComponentName
Rails.autoloaders.main.push_dir(
  "#{Rails.root}/app/components/ruby_ui", namespace: RubyUI
)

# Allow using RubyUI::ComponentName instead RubyUI::ComponentName::ComponentName
# data_table_pagination/ is intentionally excluded from collapse so that
# RubyUI::DataTablePagination is a proper module (adapter namespace).
collapse_dirs = Dir.glob(Rails.root.join("app/components/ruby_ui/*")).reject do |path|
  path.end_with?("data_table_pagination")
end
Rails.autoloaders.main.collapse(collapse_dirs) unless collapse_dirs.empty?
