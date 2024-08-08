require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage 95
  add_filter "/lib/govuk_web_banners/version.rb"
end

ENV["RAILS_ENV"] = "test"
require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

require "byebug"
require "fakeredis/rspec"
require "govuk_test"

require "govuk_web_banners/test_helpers/emergency_banner"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include GovukWebBanners::TestHelpers::EmergencyBanner
end
