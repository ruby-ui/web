# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    def initialize(src: nil, **attrs)
      @src = src
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "w-full space-y-4",
        data: {
          controller: "ruby-ui--data-table",
          ruby_ui__data_table_src_value: @src
        }
      }
    end
  end
end
