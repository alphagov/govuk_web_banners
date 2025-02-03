module GovukWebBanners
  module Validators
    class Base
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

      def overlap?(banner, other_banner)
        return false unless banner.start_date && other_banner.start_date

        other_banner.start_date < banner.end_date &&
          other_banner.end_date > banner.start_date
      end
    end
  end
end
