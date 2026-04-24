# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    register_element :turbo_frame, tag: "turbo-frame"

    def initialize(id:, action: "", **attrs)
      @frame_id = id
      @action = action
      super(**attrs)
    end

    def view_template(&block)
      turbo_frame(id: @frame_id, target: "_top") do
        div(**attrs) do
          form(action: @action, method: "post", data: {controller: "ruby-ui--data-table"}) do
            input(type: "hidden", name: "authenticity_token", value: csrf_token)
            yield if block
          end
        end
      end
    end

    private

    def default_attrs
      {class: "w-full space-y-4"}
    end

    def csrf_token
      helpers.respond_to?(:form_authenticity_token) ? helpers.form_authenticity_token : SecureRandom.hex(32)
    end
  end
end
