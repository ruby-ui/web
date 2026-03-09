require_relative "lib/ruby_ui/version"

Gem::Specification.new do |s|
  s.name = "seth_ruby_ui"
  s.version = RubyUI::VERSION
  s.summary = "RubyUI is a UI Component Library built on Phlex."
  s.description = "RubyUI is a UI Component Library for Ruby developers. Built on top of the Phlex framework."
  s.authors = ["Seth Horsley"]
  s.files = Dir["README.md", "LICENSE.txt", "lib/**/*", "app/components/ruby_ui/**/*"]
  s.require_paths = ["lib"]
  s.homepage = "https://rubygems.org/gems/ruby_ui"
  s.license = "MIT"

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "phlex", ">= 2.0"
  s.add_dependency "rouge"
  s.add_dependency "tailwind_merge", ">= 0.12"
end
