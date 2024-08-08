module GovukWebBanners
  module TestHelpers
    module EmergencyBanner
      def set_valid_emergency_banner(campaign_class: "national-emergency",
                                     heading: "Some important information",
                                     short_description: "Something important has happened",
                                     link: "https://www.emergency.gov.uk",
                                     link_text: "See more")
        confirm_fake_redis_or_raise

        Redis.new.hmset(
          :emergency_banner,
          :campaign_class,
          campaign_class,
          :heading,
          heading,
          :short_description,
          short_description,
          :link,
          link,
          :link_text,
          link_text,
        )
      end

      def set_invalid_emergency_banner
        set_valid_emergency_banner(campaign_class: "")
      end

      def set_notable_death_banner
        set_valid_emergency_banner(campaign_class: "noteable-death",
                                   short_description: "Someone important died")
      end

      def confirm_fake_redis_or_raise
        # :nocov:
        return if Module.const_defined?(:FakeRedis)

        raise(StandardError, "FakeRedis isn't defined, it's dangerous to use these test helpers!")
        # :nocov:
      end
    end
  end
end
