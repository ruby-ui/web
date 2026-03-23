# frozen_string_literal: true

module RubyUI
  class DataTableContent < Base
    def initialize(frame_id: "data_table_content", **attrs)
      @frame_id = frame_id
      super(**attrs)
    end

    def view_template(&)
      div(id: @frame_id, **attrs, &)
    end

    private

    def default_attrs
      {
        class: "rounded-md border"
      }
    end
  end
end
