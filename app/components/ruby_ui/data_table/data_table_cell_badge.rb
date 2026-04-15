# frozen_string_literal: true

module RubyUI
  # Colored pill badge. `colors:` maps values to Tailwind class strings.
  # `fallback:` is the class applied when the value isn't in `colors`.
  class DataTableCellBadge < Base
    def initialize(key:, colors: {}, fallback: "bg-secondary text-secondary-foreground", **attrs)
      @key = key
      @colors = colors
      @fallback = fallback
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_colors: @colors.to_json,
        cell_fallback_classes: @fallback
      }) do
        span(
          class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
          data: {field: true, apply_colors: true}
        )
      end
    end
  end
end
