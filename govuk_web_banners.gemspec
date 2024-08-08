require_relative "lib/govuk_web_banners/version"

Gem::Specification.new do |spec|
  spec.name        = "govuk_web_banners"
  spec.version     = GovukWebBanners::VERSION
  spec.authors     = ["GOV.UK Dev"]
  spec.email       = ["govuk-dev@digital.cabinet-office.gov.uk"]
  spec.homepage    = "https://github.com/alphagov/govuk_web_banners"
  spec.summary     = "A gem to support banners on GOV.UK frontend applications"
  spec.description = "A gem to support banners on GOV.UK frontend applications"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.1"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.github.com/alphagov/govuk_web_banners"
  spec.metadata["changelog_uri"] = "https://www.github.com/alphagov/govuk_web_banners/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "govuk_app_config"
  spec.add_dependency "govuk_publishing_components"
  spec.add_dependency "rails", ">= 7"
  spec.add_dependency "redis"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "fakeredis", "~> 0.9"
  spec.add_development_dependency "govuk_test"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop-govuk"
  spec.add_development_dependency "simplecov"
end
