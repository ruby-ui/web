# frozen_string_literal: true

module Views
  module Layouts
    class PagesLayout < Views::Base
      include Phlex::Rails::Layout

      def initialize(page_info = nil, **user_attrs)
        @page_info = page_info
        super(**user_attrs)
      end

      def view_template
        doctype

        html do
          render Shared::Head.new

          body do
            render Shared::Navbar.new
            main(class: "relative") { yield }
            render Shared::Flashes.new(notice: flash[:notice], alert: flash[:alert])
          end
        end
      end
    end
  end
end
