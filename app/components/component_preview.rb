module Components
  class ComponentPreview < Components::Base
    def initialize(ruby_code: nil, title: nil, description: nil, src: nil, context: nil, type: :component, content: nil, content_attributes: nil)
      @ruby_code = ruby_code
      @title = title
      @description = description
      @src = src
      @context = context
      @type = type
      @content = content
      @content_attributes = content_attributes
    end

    def view_template(&)
      if @type == :block && @content
        div(class: "relative aspect-[4/2.5] w-full overflow-hidden rounded-md border md:-mx-1", data: {controller: "iframe-theme"}) do
          iframe(src: render_block_path(id: @content.to_s, attributes: @content_attributes), class: "size-full", data: {iframe_theme_target: "iframe"})
        end
      else
        render ComponentPreviewTabs.new(title: @title, description: @description, context: @context, ruby_code: @ruby_code) { capture(&) }
      end
    end
  end
end
