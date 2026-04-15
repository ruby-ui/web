# frozen_string_literal: true

module RubyUI
  # Anchor cell. `href:` supports `{value}` placeholder substitution.
  # `label:` optionally fixes the link text (defaults to the cell value).
  # `target:` sets the anchor target attribute.
  class DataTableCellLink < Base
    def initialize(key:, href: "{value}", label: nil, target: "_self", **attrs)
      @key = key
      @href = href
      @label = label
      @target = target
      super(**attrs)
    end

    def view_template
      template(data: {
        ruby_ui__data_table_target: "tplCell_#{@key}",
        cell_href_template: @href,
        cell_target: @target
      }) do
        a(
          class: "underline underline-offset-2 hover:text-primary",
          target: @target,
          data: {field: @label.nil?, apply_href: true}
        ) do
          plain @label if @label
        end
      end
    end
  end
end
