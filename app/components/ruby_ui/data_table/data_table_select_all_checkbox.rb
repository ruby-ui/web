# frozen_string_literal: true

module RubyUI
  class DataTableSelectAllCheckbox < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        type: "checkbox",
        aria_label: "Select all",
        class: "peer h-4 w-4 shrink-0 rounded-sm border-input accent-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        data: {
          "ruby-ui--data-table-target": "selectAll",
          action: "change->ruby-ui--data-table#toggleAll"
        }
      }
    end
  end
end
