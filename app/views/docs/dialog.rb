# frozen_string_literal: true

class Views::Docs::Dialog < Views::Base
  def view_template
    component = "Dialog"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dialog", description: "A window overlaid on either the primary window or another dialog window, rendering the content underneath inert.")

      Heading(level: 2) { "Usage" }

      div(class: "data-[state=show]:animate-in data-[state=hide]:animate-out fade-in slide-in-from-top-8 fade-out slide-out-to-top-8 duration-500", data: {state: "hide"}) do
        p do
          plain "If the element has the "
          code { plain "data-state=\"show\"" }
          plain " attribute, fade in from 0% opacity, slide from top by 8 spacing units (2rem), with a 500ms duration."
        end
      end

      div(class: "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95", data: {state: "closed"}) do
        p do
          "Fade in from 0% opacity,"
          "slide from top by 8 spacing units (2rem),"
          "with a 500ms duration."
        end
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Dialog do
            DialogTrigger do
              Button { "Open Dialog" }
            end
            # class: "backdrop:bg-black/80 border-red-500 border-2"
            DialogContent() do
              DialogHeader do
                DialogTitle { "RubyUI to the rescue" }
                DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
              end
              DialogMiddle do
                AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                  img(
                    alt: "Placeholder",
                    loading: "lazy",
                    src: image_path("pattern.jpg")
                  )
                end
              end
              DialogFooter do
                Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Cancel" }
                Button { "Save" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Size", description: "Applicable for wider screens", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap justify-center gap-2') do
            Dialog do
              DialogTrigger do
                Button { "Small Dialog" }
              end
              DialogContent(size: :sm) do
                DialogHeader do
                  DialogTitle { "RubyUI to the rescue" }
                  DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
                end
                DialogMiddle do
                  AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src: image_path("pattern.jpg")
                    )
                  end
                end
                DialogFooter do
                  Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Cancel" }
                  Button { "Save" }
                end
              end
            end

            Dialog do
              DialogTrigger do
                Button { "Large Dialog" }
              end
              DialogContent(size: :lg) do
                DialogHeader do
                  DialogTitle { "RubyUI to the rescue" }
                  DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
                end
                DialogMiddle do
                  AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src: image_path("pattern.jpg")
                    )
                  end
                end
                DialogFooter do
                  Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Cancel" }
                  Button { "Save" }
                end
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
