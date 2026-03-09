# frozen_string_literal: true

module Components
  class ComponentRender < Components::Base
    def initialize(context:, ruby_code: nil)
      @ruby_code = ruby_code
      @context = context
    end

    def view_template(&)
      @display_code = @ruby_code || CGI.unescapeHTML(capture(&))
      decoded_code = CGI.unescapeHTML(@display_code)
      @context.instance_eval(decoded_code)
    end
    # standard:enable Style/ArgumentsForwarding
  end
end
