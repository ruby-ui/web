# frozen_string_literal: true

module RubyUI
  class DataTableAvoSearch < Base
    # @param path [String] form action — where the search is submitted
    # @param frame_id [String] id of the parent <turbo-frame> the response targets
    # @param value [String, nil] current search value
    # @param name [String] query param name (default "search")
    # @param placeholder [String]
    def initialize(path:, frame_id:, value: nil, name: "search", placeholder: "Search...", **attrs)
      @path = path
      @frame_id = frame_id
      @value = value
      @name = name
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template
      form(**attrs) do
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
      {
        action: @path,
        method: "get",
        data: {turbo_frame: @frame_id},
        class: "max-w-sm flex-1"
      }
    end
  end
end
