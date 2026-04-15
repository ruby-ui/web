# frozen_string_literal: true

module RubyUI
  class DataTableExpandedRow < Base
    # Wraps expanded-row content in a <template>. Stimulus clones it per
    # expanded row and fills elements marked with `data-field="columnKey"`
    # with the corresponding row value.
    def view_template(&)
      template(**attrs, &)
    end

    private

    def default_attrs
      {data: {ruby_ui__data_table_target: "tplExpandedRow"}}
    end
  end
end
