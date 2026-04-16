# frozen_string_literal: true

module RubyUI
  class DataTableAvo < Base
    register_element :turbo_frame, tag: "turbo-frame"

    def initialize(id:, **attrs)
      @frame_id = id
      super(**attrs)
    end

    def view_template(&)
      turbo_frame(id: @frame_id, target: "_top") do
        div(**attrs, &)
      end
    end

    private

    def default_attrs
      {
        class: "w-full space-y-4",
        data: {controller: "ruby-ui--data-table-avo"}
      }
    end
  end
end
