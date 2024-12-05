require "govuk_app_config/govuk_error"
require "redis"

module GovukWebBanners
  class EmergencyBanner
    def self.banner
      @client ||= Redis.new(
        url: ENV["EMERGENCY_BANNER_REDIS_URL"],
        reconnect_attempts: [15, 30, 45, 60],
      )
      GovukWebBanners::EmergencyBanner.new(@client)
    end

    attr_reader :campaign_class, :heading, :short_description, :link, :link_text

    def initialize(client)
      content = content_from_redis(client)

      @campaign_class = content[:campaign_class].presence
      @heading = content[:heading].presence
      @short_description = content[:short_description].presence
      @link = content[:link].presence
      @link_text = content[:link_text].presence
    end

    def active?
      [campaign_class, heading].all?
    end

  private

    def content_from_redis(client)
      client.hgetall("emergency_banner").try(:symbolize_keys)
    rescue StandardError => e
      GovukError.notify(e, extra: { context: "Emergency Banner Redis" })
      {}
    end
  end
end
