class Components::BlockViewer < Components::Base
  def view_template
    render ComponentPreview.new(title: "Example", context: self) do
      <<~RUBY
        Button(disabled: true) { "Disabled" }
      RUBY
    end

    render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
      <<~RUBY
        Button(disabled: true) { "Disabled" }
      RUBY
    end

    # render ComponentPreview.new(
    #   title: "Example",
    #   context: self,
    #   type: :block,
    #   content: Blocks::Sidebar02::Index,
    #   content_attributes: {sidebar_state: "open"}
    # )
  end
end
