# frozen_string_literal: true

module RubyUI
  class DataTablePerPageSelect < Base
    def initialize(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @options = options
      super(**attrs)
    end

    def view_template
      form_attrs = {action: @path, method: "get"}
      form_attrs[:data] = {turbo_frame: @frame_id} if @frame_id

      form(**attrs.merge(form_attrs)) do
        div(class: "group/native-select relative w-fit") do
          select(
            name: @name,
            onchange: safe("this.form.requestSubmit()"),
            class: [
              "border-border bg-transparent text-sm w-full min-w-0 appearance-none rounded-md border py-1 pr-8 pl-2.5 shadow-xs transition-[color,box-shadow] outline-none select-none ring-0 ring-ring/0",
              "focus-visible:outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-2",
              "h-9"
            ]
          ) do
            @options.each do |opt|
              option_attrs = {value: opt.to_s}
              option_attrs[:selected] = true if opt.to_s == @value.to_s
              option(**option_attrs) { plain opt.to_s }
            end
          end
          render RubyUI::NativeSelectIcon.new
        end
      end
    end

    private

    def default_attrs
      {}
    end
  end
end
