# frozen_string_literal: true

module RubyUI
  class CalendarInput < Input
    def initialize(calendar_id: nil, format: "MM-dd-yyyy", placeholder: nil, label_animation: true, label_classes: nil, label_separator: " - ex: ", **attrs)
      @calendar_id = calendar_id
      @format = format
      @placeholder = placeholder || default_placeholder_for_format(format)
      @label_animation = label_animation
      @label_classes = label_classes || "text-xs text-gray-500 -mt-2 transition-all duration-200"
      @label_separator = label_separator
      super(type: :string, **attrs)
    end

    def view_template
      input(**attrs)
    end

    private

    def default_placeholder_for_format(format)
      case format
      when "MM-dd-yyyy"
        "(01-16-1998)"
      when "dd-MM-yyyy"
        "(16-01-1998)"
      else
        "(01-16-1998)"
      end
    end

    def default_attrs
      parent_attrs = super
      parent_attrs.merge(
        placeholder: @placeholder,
        data: parent_attrs[:data].merge(
          controller: "ruby-ui--calendar-input",
          ruby_ui__calendar_input_format_value: @format,
          ruby_ui__calendar_input_placeholder_value: @placeholder,
          ruby_ui__calendar_input_label_animation_value: @label_animation,
          ruby_ui__calendar_input_label_classes_value: @label_classes,
          ruby_ui__calendar_input_label_separator_value: @label_separator,
          ruby_ui__calendar_input_ruby_ui__calendar_outlet: @calendar_id
        )
      )
    end
  end
end
