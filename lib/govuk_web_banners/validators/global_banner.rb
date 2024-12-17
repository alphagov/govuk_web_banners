require "active_support/core_ext/integer/time"
require "open-uri"

module GovukWebBanners
  module Validators
    class GlobalBanner < GovukWebBanners::Validators::Base
    private

      def validate(banners)
        banners.each do |banner|
          add_error(banner, "is missing a title") unless banner.title.present?
          add_error(banner, "is missing a text") unless banner.text.present?
          add_error(banner, "has both a title_href and a text_href") if banner.title_href.present? && banner.text_href.present?
          add_error(banner, "start_date is after end_date") unless banner.start_date < banner.end_date

          if banner.href.present?
            begin
              if banner.href.start_with?("/")
                URI.open("https://www.gov.uk/api/content#{banner.href}")
              else
                add_error(banner, "href #{banner.href} should start with a /")
              end
            rescue OpenURI::HTTPError
              add_warning(banner, "refers to a path #{banner.href} which is not currently live on gov.uk")
            end
          else
            add_error(banner, "is missing a title_href or text_href")
          end

          other_banners = banners - [banner]
          other_banners.each do |other_banner|
            add_error(banner, "is active at the same time as #{safe_name(other_banner)}") if overlap?(banner, other_banner)
          end

          add_warning(banner, "is expired") unless banner.end_date >= Time.now
        end
      end

      def overlap?(banner, other_banner)
        other_banner.start_date < banner.end_date &&
          other_banner.end_date > banner.start_date
      end
    end
  end
end
