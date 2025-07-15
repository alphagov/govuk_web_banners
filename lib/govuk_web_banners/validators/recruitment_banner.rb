require "active_support/core_ext/integer/time"
require "open-uri"

require "govuk_web_banners/validators/base"

module GovukWebBanners
  module Validators
    class RecruitmentBanner < GovukWebBanners::Validators::Base
    private

      def validate(banners)
        banners.each do |banner|
          add_error(banner, "is missing a suggestion_text") unless banner.suggestion_text.present?
          add_error(banner, "is missing a suggestion_link_text") unless banner.suggestion_link_text.present?
          add_error(banner, "is missing a survey_url") unless banner.survey_url.present?
          add_error(banner, "is missing any page_paths") unless banner.page_paths.present?
          add_error(banner, "start_date is after end_date") unless banner.start_date < banner.end_date
          add_error(banner, "includes an invalid image value (#{banner.image})") unless banner.image == "hmrc" || banner.image.nil?

          (banner.page_paths || []).each do |path|
            if path.start_with?("/")
              URI.open("https://www.gov.uk/api/content#{path}")
            else
              add_error(banner, "page_path #{path} should start with a /")
            end
          rescue OpenURI::HTTPError
            add_warning(banner, "refers to a path #{path} which is not currently live on gov.uk")
          end

          other_banners = banners - [banner]
          other_banners.each do |other_banner|
            next unless overlap?(banner, other_banner)

            banner_paths = banner.page_paths || []
            other_banner_paths = other_banner.page_paths || []
            add_error(banner, "is active at the same time as #{safe_name(other_banner)} and points to the same paths") if banner_paths.intersect?(other_banner_paths)
          end

          add_warning(banner, "is expired") unless banner.end_date >= Time.now
        end
      end
    end
  end
end
