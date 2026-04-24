# frozen_string_literal: true

module RubyUI
  class DataTableExpandToggle < Base
    def initialize(controls:, expanded: false, label: "Toggle row details", **attrs)
      @controls = controls
      @expanded = expanded
      @label = label
      super(**attrs)
    end

    def view_template
      button(
        type: "button",
        aria_expanded: @expanded.to_s,
        aria_controls: @controls,
        aria_label: @label,
        data: {
          action: "click->ruby-ui--data-table#toggleRowDetail"
        },
        **attrs
      ) do
        render_icon
      end
    end

    private

    def render_icon
      raw view_context.lucide_icon("chevron-right", class: "h-4 w-4 transition-transform duration-150 aria-expanded:rotate-90 [button[aria-expanded='true']_&]:rotate-90")
    end

    def default_attrs
      {
        class: "inline-flex items-center justify-center h-8 w-8 rounded-md hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      }
    end
  end
end
