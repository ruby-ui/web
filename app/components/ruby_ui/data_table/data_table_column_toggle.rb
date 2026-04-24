# frozen_string_literal: true

module RubyUI
  class DataTableColumnToggle < Base
    def initialize(columns:, **attrs)
      @columns = columns
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        render RubyUI::DropdownMenu.new do
          render RubyUI::DropdownMenuTrigger.new do
            render RubyUI::Button.new(variant: :outline, size: :sm) do
              plain "Columns"
              icon = view_context.respond_to?(:lucide_icon) ? raw(view_context.lucide_icon("chevron-down", class: "w-4 h-4 ml-1")) : nil
              icon
            end
          end
          render RubyUI::DropdownMenuContent.new do
            @columns.each do |col|
              label(class: "flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer hover:bg-accent") do
                input(
                  type: "checkbox",
                  checked: true,
                  class: "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
                  data: {
                    column_key: col[:key].to_s,
                    action: "change->ruby-ui--data-table-column-visibility#toggle"
                  }
                )
                span { plain col[:label] }
              end
            end
          end
        end
      end
    end

    private

    def default_attrs
      {
        class: "relative",
        data: {controller: "ruby-ui--data-table-column-visibility"}
      }
    end
  end
end
