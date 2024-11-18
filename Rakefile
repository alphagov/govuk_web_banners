require "bundler/setup"
require "rubocop/rake_task"
require "rspec/core/rake_task"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

require "govuk_web_banners/validators/recruitment_banner"
require "rainbow"

desc "show errors in the live config"
task :check_config do
  validator = GovukWebBanners::Validators::RecruitmentBanner.new(GovukWebBanners::RecruitmentBanner.all_banners)

  if !validator.valid?
    puts Rainbow("\nLive config contains errors!").red
    validator.errors.each_key do |key|
      puts(key)
      validator.errors[key].each { |error| puts(" - #{error}") }
    end
    puts
    exit(1)
  elsif validator.warnings?
    puts Rainbow("\nLive config is valid, but with warnings").yellow
    validator.warnings.each_key do |key|
      puts(key)
      validator.warnings[key].each { |warnings| puts(" - #{warnings}") }
    end
    puts
  else
    puts Rainbow("\nLive config is valid!\n").green
  end
rescue StandardError => e
  puts(e)
  puts("Live config could not be read (if there are no banners, check banner key is marked as an empty array - banners: [])")
  exit(1)
end

task default: %i[check_config rubocop spec]
