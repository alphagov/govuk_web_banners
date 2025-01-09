require "active_support/core_ext/integer/time"
require "open-uri"

module GovukWebBanners
  module Validators
    class GlobalBanner < GovukWebBanners::Validators::Base
    private

      def validate(banners)
        banners.each do |banner|
          add_error(banner, "must have at least one item in the items list") unless banner.items.present? && banner.items.count.positive?

          if banner.items.present?
            banner.items.each_with_index do |item, i|
              add_error(banner, "item #{i} is missing a title") unless item.title.present?
              add_error(banner, "item #{i} is missing a title_path") unless item.title_path.present?
              add_error(banner, "item #{i} is missing an info_text") unless item.info_text.present?

              next unless item.title_path.present?

              begin
                if item.title_path.start_with?("/")
                  URI.open("https://www.gov.uk/api/content#{item.title_path}")
                else
                  add_error(banner, "item #{i} title_path #{item.title_path} should start with a /")
                end
              rescue OpenURI::HTTPError
                add_warning(banner, "item #{i} refers to a path #{item.title_path} which is not currently live on gov.uk")
              end
            end
          end

          add_error(banner, "start_date is after end_date") unless banner.start_date < banner.end_date

          other_banners = banners - [banner]
          other_banners.each do |other_banner|
            add_error(banner, "is active at the same time as #{safe_name(other_banner)}") if overlap?(banner, other_banner)
          end

          banner.exclude_paths.each do |exclude_path|
            next unless exclude_path # ignore nil exclude paths, which are missing title_paths (validated higher up)

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

      def overlap?(banner, other_banner)
        other_banner.start_date < banner.end_date &&
          other_banner.end_date > banner.start_date
      end
    end
  end
end
