begin
  require "rails/generators"
rescue LoadError
  # Rails not available, skip generator definition
end

if defined?(Rails::Generators::Base)
  module RubyUI
    module Generators
      module Component
        class AllGenerator < Rails::Generators::Base
          namespace "ruby_ui:component:all"

          source_root File.expand_path("../../../../app/components/ruby_ui", __dir__)
          class_option :force, type: :boolean, default: false

          def generate_components
            say "Generating all components..."

            Dir.children(self.class.source_root).each do |folder_name|
              next if folder_name.ends_with?(".rb")

              run "bin/rails generate ruby_ui:component #{folder_name} --force #{options["force"]}"
            end
          end
        end
      end
    end
  end
end
