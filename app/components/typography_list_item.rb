# frozen_string_literal: true

class Components::TypographyListItem < RBUI::Base
  def view_template(&)
    li(**attrs, &)
  end

  private

  def default_attrs
    {
      class: "leading-7"
    }
  end
end
