# frozen_string_literal: true

require_relative "../llms_txt_generator"

# Rake task to generate /public/llms.txt from doc views.
#
# Usage:
#   rake llms:generate
#   rake llms:generate[https://rubyui.com]  # custom base URL

namespace :llms do
  desc "Generate public/llms.txt from doc view files"
  task :generate, [:base_url] do |_t, args|
    docs_dir = File.expand_path("../../app/views/docs", __dir__)
    output_path = File.expand_path("../../public/llms.txt", __dir__)

    generator = LlmsTxtGenerator.new(
      docs_dir: docs_dir,
      base_url: args[:base_url] || "https://rubyui.com"
    )

    count = generator.write(output_path)
    puts "Generated #{output_path} (#{count} components)"
  end
end

# Auto-generate llms.txt during assets:precompile (Heroku & Docker builds)
if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance do
    Rake::Task["llms:generate"].invoke
  end
end
