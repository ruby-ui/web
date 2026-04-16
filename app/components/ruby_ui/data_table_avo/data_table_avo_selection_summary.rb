# frozen_string_literal: true

module RubyUI
  class DataTableAvoSelectionSummary < Base
    # Displays "X of Y row(s) selected" — updated client-side by the Stimulus
    # controller as row checkboxes toggle. The initial text matches the
    # server-rendered page of rows so the label is correct before JS boots.
    def initialize(total_on_page:, **attrs)
      @total_on_page = total_on_page
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        plain "0 of #{@total_on_page} row(s) selected."
      end
    end

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground",
        data: {ruby_ui__data_table_avo_target: "selectionSummary"}
      }
    end
  end
end
