require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage 95
end

ENV["RAILS_ENV"] = "test"
require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

require "byebug"
require "govuk_test"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

RSpec.configure(&:infer_spec_type_from_file_location!)
