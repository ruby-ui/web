# frozen_string_literal: true

module RubyUI
  class DataTablePerPage < Base
    def initialize(options: [10, 20, 50, 100], current: 10, **attrs)
      @options = options
      @current = current
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        span(class: "text-sm text-muted-foreground") { "Rows per page" }
        render RubyUI::NativeSelect.new(
          size: :sm,
          class: "w-16",
          data: {
            action: "change->ruby-ui--data-table#changePerPage",
            ruby_ui__data_table_target: "perPage"
          }
        ) do
          @options.each do |opt|
            render RubyUI::NativeSelectOption.new(value: opt, selected: opt == @current) { opt.to_s }
          end
        end
      end
    end

    private

    def default_attrs
      {
        class: "flex items-center gap-2"
      }
    end
  end
end
