ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Renders a Phlex component with a Rails view context so helpers like
  # `view_context.lucide_icon` and `view_context.form_authenticity_token`
  # are available. Components that call these must use this helper in tests.
  def render_component(component, &block)
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    vc = controller.view_context
    component.call(context: {rails_view_context: vc}, &block)
  end
end

class ActionDispatch::IntegrationTest
  setup do
    host! "example.com"
  end
end
