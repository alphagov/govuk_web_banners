require "active_support/core_ext/integer/time"
require "open-uri"

require "govuk_web_banners/validators/base"

module GovukWebBanners
  module Validators
    class GlobalBanner < GovukWebBanners::Validators::Base
    private

      def validate(banners)
        banners.each do |banner|
          add_error(banner, "is missing a title") unless banner.title.present?
          add_error(banner, "is missing a title_href") unless banner.title_href.present?
          add_error(banner, "is missing a text") unless banner.text.present?

          if banner.title_href&.start_with?("/")
            begin
              URI.open("https://www.gov.uk/api/content#{banner.title_href}")
            rescue OpenURI::HTTPError
              add_warning(banner, "refers to a path #{banner.title_href} which is not currently live on gov.uk")
            end
          end

          if banner.start_date.present?
            add_error(banner, "start_date is after end_date") unless banner.start_date < banner.end_date
          else
            add_error(banner, "is missing a start_date")
          end

          other_banners = banners - [banner]
          other_banners.each do |other_banner|
            add_warning(banner, "is active at the same time as #{safe_name(other_banner)}") if overlap?(banner, other_banner)
          end

          banner.exclude_paths.each do |exclude_path|
            if exclude_path.start_with?("/")
              URI.open("https://www.gov.uk/api/content#{exclude_path}")
            else
              add_error(banner, "exclude_path #{exclude_path} should start with a /")
            end
          rescue OpenURI::HTTPError
            add_warning(banner, "refers to an exclude_path #{exclude_path} which is not currently live on gov.uk")
          end

          add_warning(banner, "is expired") unless banner.end_date >= Time.now
        end
      end
    end
  end
end
