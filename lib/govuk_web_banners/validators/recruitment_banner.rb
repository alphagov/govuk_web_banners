require "active_support/core_ext/integer/time"
require "open-uri"

module GovukWebBanners
  module Validators
    class RecruitmentBanner
      attr_reader :errors, :warnings

      def initialize(banners)
        @errors = {}
        @warnings = {}

        validate(banners)
      end

      def valid?
        @errors.keys.none?
      end

      def warnings?
        @warnings.keys.any?
      end

    private

      def add_error(banner, error)
        @errors[safe_name(banner)] ||= []
        @errors[safe_name(banner)] << error
      end

      def add_warning(banner, warning)
        @warnings[safe_name(banner)] ||= []
        @warnings[safe_name(banner)] << warning
      end

      def safe_name(banner)
        banner.name || "unnamed banner"
      end

      def validate(banners)
        banners.each do |banner|
          add_error(banner, "is missing a suggestion_text") unless banner.suggestion_text.present?
          add_error(banner, "is missing a suggestion_link_text") unless banner.suggestion_link_text.present?
          add_error(banner, "is missing a survey_url") unless banner.survey_url.present?
          add_error(banner, "is missing any page_paths") unless banner.page_paths.present?

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

      def overlap?(banner, other_banner)
        other_banner.start_date < banner.end_date &&
          other_banner.end_date > banner.start_date
      end
    end
  end
end
