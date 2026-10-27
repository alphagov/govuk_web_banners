require "govuk_app_config/govuk_error"

module GovukWebBanners
  class EmergencyBanner
    CONFIG_LOCATION = "/etc/emergency-banner/config.yaml".freeze

    attr_reader :campaign_class, :heading, :short_description, :link, :link_text

    def initialize
      content = content_from_yaml

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

    def content_from_yaml
      YAML.load_file(CONFIG_LOCATION, symbolize_names: true)
    rescue StandardError => e
      GovukError.notify(e, extra: { context: "Emergency Banner configMap" })
      {}
    end
  end
end
