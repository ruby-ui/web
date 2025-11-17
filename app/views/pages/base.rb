class Views::Pages::Base < Views::Base
  PageInfo = Data.define(:title)

  def around_template
    render layout.new(page_info) do
      super
    end
  end

  def page_info
    PageInfo.new(
      title: page_title
    )
  end
end
