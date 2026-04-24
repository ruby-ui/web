# frozen_string_literal: true

module RubyUI
  class DataTableSelectionBar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex items-center justify-between gap-4 py-2",
        data: {"ruby-ui--data-table-target": "selectionBar"}
      }
    end
  end
end
