# frozen_string_literal: true

module RubyUI
  class DataTableSearch < Base
    def initialize(placeholder: "Search...", name: "search", **attrs)
      @placeholder = placeholder
      @name = name
      super(**attrs)
    end

    def view_template
      render RubyUI::Input.new(
        type: :search,
        name: @name,
        placeholder: @placeholder,
        **attrs
      )
    end

    private

    def default_attrs
      {
        class: "max-w-sm",
        data: {
          ruby_ui__data_table_target: "search",
          action: "input->ruby-ui--data-table#search"
        }
      }
    end
  end
end
