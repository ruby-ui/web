# frozen_string_literal: true

module RubyUI
  class DataTableRowCheckbox < Base
    def initialize(value:, name: "ids[]", **attrs)
      @value = value
      @name = name
      super(**attrs)
    end

    def view_template
      render RubyUI::Checkbox.new(**attrs)
    end

    private

    def default_attrs
      {
        name: @name,
        value: @value,
        aria_label: "Select row #{@value}",
        data: {
          "ruby-ui--data-table-target": "rowCheckbox",
          action: "change->ruby-ui--data-table#toggleRow"
        }
      }
    end
  end
end
