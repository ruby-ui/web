# frozen_string_literal: true

class Components::Layouts::Docs < Components::Layouts::Base
  include ApplicationHelper

  def around_template
    super do # Call the Base layout's template method
      div(class: "flex-1") do
        div(class: "border-b") do
          div(class: "container px-4 flex-1 items-start md:grid md:grid-cols-[220px_minmax(0,1fr)] md:gap-6 lg:grid-cols-[240px_minmax(0,1fr)] lg:gap-10") do
            render Components::Shared::Sidebar.new
            main(class: "relative py-6 lg:gap-10 lg:py-8 xl:grid xl:grid-cols-[1fr_300px]") do
              yield # This will render the content of views using this layout
            end
          end
        end
      end
    end
  end
end
