# frozen_string_literal: true

module RubyUI
  class DataTableRowCheckbox < Base
    def initialize(value:, name: "ids[]", **attrs)
      @value = value
      @name = name
      super(**attrs)
    end

    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        type: "checkbox",
        name: @name,
        value: @value,
        aria_label: "Select row #{@value}",
        class: "peer h-4 w-4 shrink-0 rounded-sm border-input accent-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        data: {
          "ruby-ui--data-table-target": "rowCheckbox",
          action: "change->ruby-ui--data-table#toggleRow"
        }
      }
    end
  end
end
