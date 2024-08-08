require "govuk_web_banners/engine"
require "govuk_web_banners/version"

require "govuk_web_banners/app_helpers/banners_helper"
require "govuk_web_banners/emergency_banner"
require "govuk_web_banners/recruitment_banner"

module GovukWebBanners
  def self.root
    File.expand_path("..", __dir__)
  end
end
