require "bundler/setup"
require "rubocop/rake_task"
require "rspec/core/rake_task"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

require "govuk_web_banners/validators/global_banner"
require "govuk_web_banners/validators/recruitment_banner"
require "rainbow"

def output_validator_info(validator, name)
  if !validator.valid?
    puts Rainbow("\nLive #{name} config contains errors!").red
    validator.errors.each_key do |key|
      puts(key)
      validator.errors[key].each { |error| puts(" - #{error}") }
    end
    puts
    exit(1)
  elsif validator.warnings?
    puts Rainbow("\nLive #{name} config is valid, but with warnings").yellow
    validator.warnings.each_key do |key|
      puts(key)
      validator.warnings[key].each { |warnings| puts(" - #{warnings}") }
    end
    puts
  else
    puts Rainbow("\nLive #{name} config is valid!\n").green
  end
end

desc "show errors in the live global banner config"
task :check_global_config do
  validator = GovukWebBanners::Validators::GlobalBanner.new(GovukWebBanners::GlobalBanner.all_banners)
  output_validator_info(validator, "global banner")
rescue StandardError => e
  puts(e)
  puts Rainbow("Live global banner config could not be read (if there are no banners, check global_banner key is marked as an empty array - global_banners: [])").red
  exit(1)
end

desc "show errors in the live recruitment banner config"
task :check_recruitment_config do
  validator = GovukWebBanners::Validators::RecruitmentBanner.new(GovukWebBanners::RecruitmentBanner.all_banners)
  output_validator_info(validator, "recruitment banner")
rescue StandardError => e
  puts(e)
  puts Rainbow("Live recruitment banner config could not be read (if there are no banners, check banner key is marked as an empty array - banners: [])").red
  exit(1)
end

task default: %i[check_global_config check_recruitment_config rubocop spec]
