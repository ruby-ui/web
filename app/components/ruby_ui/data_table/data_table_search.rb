# frozen_string_literal: true

module RubyUI
  class DataTableSearch < Base
    def initialize(path:, name: "search", value: nil, frame_id: nil, placeholder: "Search...", **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template
      form_attrs = {method: "get", action: @path}
      form_attrs[:data] = {turbo_frame: @frame_id} if @frame_id

      form(**attrs.merge(form_attrs)) do
        render RubyUI::Input.new(
          type: :search,
          name: @name,
          value: @value,
          placeholder: @placeholder,
          autocomplete: "off"
        )
      end
    end

    private

    def default_attrs
      {class: "max-w-sm flex-1"}
    end
  end
end
