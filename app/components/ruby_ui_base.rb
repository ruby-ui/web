# frozen_string_literal: true

class Components::RubyUiBase < Phlex::HTML
  include RBUI
  # include Components
  include ApplicationHelper

  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Routes

  GITHUB_REPO_URL = "https://github.com/ruby-ui/ruby_ui/"
  GITHUB_FILE_URL = "#{GITHUB_REPO_URL}blob/main/"

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end

class MethodCallFinder < Prism::Visitor
  attr_reader :calls

  def initialize(calls)
    @calls = calls
  end

  def visit_call_node(node)
    super
    calls << node.name
  end
end
