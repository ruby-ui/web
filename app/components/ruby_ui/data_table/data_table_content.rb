# frozen_string_literal: true

module RubyUI
  class DataTableContent < Base
    def view_template
      div(**attrs) do
        table(class: "w-full caption-bottom text-sm") do
          thead(class: "[&_tr]:border-b", data: {ruby_ui__data_table_target: "thead"})
          tbody(class: "[&_tr:last-child]:border-0", data: {ruby_ui__data_table_target: "tbody"})
        end
      end
    end

    private

    def default_attrs
      {
        class: "rounded-md border"
      }
    end
  end
end
