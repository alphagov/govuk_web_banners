require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage 100
  add_filter "/lib/govuk_web_banners/version.rb"
end

ENV["RAILS_ENV"] = "test"
require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

require "byebug"
require "govuk_test"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include ActiveSupport::Testing::TimeHelpers
end
