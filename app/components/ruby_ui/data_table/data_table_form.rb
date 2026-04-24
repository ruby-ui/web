# frozen_string_literal: true

module RubyUI
  class DataTableForm < Base
    def initialize(action: "", method: "post", **attrs)
      @action = action
      @method = method
      super(**attrs)
    end

    def view_template(&block)
      form(action: @action, method: @method, **attrs) do
        input(type: "hidden", name: "authenticity_token", value: csrf_token)
        yield if block
      end
    end

    private

    def csrf_token
      return view_context.form_authenticity_token if respond_to?(:view_context) && view_context.respond_to?(:form_authenticity_token)
      SecureRandom.hex(32)
    end

    def default_attrs
      {}
    end
  end
end
