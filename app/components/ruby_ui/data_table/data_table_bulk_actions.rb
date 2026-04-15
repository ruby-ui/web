# frozen_string_literal: true

module RubyUI
  class DataTableBulkActions < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "hidden items-center gap-3",
        data: {ruby_ui__data_table_target: "bulkActions"}
      }
    end
  end
end
