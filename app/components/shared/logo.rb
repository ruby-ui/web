# frozen_string_literal: true

module Components
  module Shared
    class Logo < Components::Base
      def view_template
        a(href: root_url, class: "mr-6 flex items-center space-x-2") do
          Heading(level: 2, class: "flex items-center pb-0 border-0") do
            img(src: image_url("logo.svg"), class: "h-4 block dark:hidden")
            img(src: image_url("logo_dark.svg"), class: "h-4 hidden dark:block")
            span(class: "sr-only") { "RubyUI" }
            Badge(variant: :amber, size: :sm, class: "ml-2 whitespace-nowrap") { commit_hash }
          end
        end
      end

      private

      def commit_hash
        @commit_hash ||= ENV.fetch("GIT_COMMIT_HASH") do
          `git rev-parse --short HEAD`.strip
        rescue
          "unknown"
        end
      end
    end
  end
end
