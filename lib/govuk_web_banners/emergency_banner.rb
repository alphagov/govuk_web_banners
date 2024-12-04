require "govuk_app_config/govuk_error"
require "redis"

module GovukWebBanners
  class EmergencyBanner
    attr_reader :campaign_class, :heading, :short_description, :link, :link_text

    def initialize(redis_client:)
      content = content_from_redis(redis_client)

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
      Rails.cache.fetch("#emergency_banner/config", expires_in: 1.minute) do
        client.hgetall("emergency_banner").try(:symbolize_keys)
      end
    rescue StandardError => e
      GovukError.notify(e, extra: { context: "Emergency Banner Redis" })
      {}
    end
  end
end
