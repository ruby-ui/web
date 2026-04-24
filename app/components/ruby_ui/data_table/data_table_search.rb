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
        input(
          type: :search,
          name: @name,
          value: @value,
          placeholder: @placeholder,
          autocomplete: "off",
          class: [
            "flex h-9 w-full rounded-md border bg-background px-3 py-1 text-sm shadow-xs transition-[color,box-shadow] border-border",
            "placeholder:text-muted-foreground",
            "disabled:cursor-not-allowed disabled:opacity-50",
            "focus-visible:outline-none focus-visible:ring-ring/50 focus-visible:ring-2 focus-visible:border-ring focus-visible:shadow-sm"
          ]
        )
      end
    end

    private

    def default_attrs
      {class: "max-w-sm flex-1"}
    end
  end
end
