class Components::Layouts::Base < Phlex::HTML
  # include Components

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  PageInfo = Data.define(:title)

  def around_template
    doctype

    html do
      render Components::Shared::Head.new(page_info)

      body do
        render Components::Shared::Navbar.new
        yield # This will render the content of child layouts/views
        render Components::Shared::Flashes.new(notice: helpers.flash[:notice], alert: helpers.flash[:alert])
      end
    end
  end

  def page_info
    PageInfo.new(
      title: page_title
    )
  end
end
