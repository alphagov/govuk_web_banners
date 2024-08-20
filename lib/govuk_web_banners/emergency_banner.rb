require "govuk_app_config/govuk_error"
require "redis"
require "uri"

module GovukWebBanners
  class EmergencyBanner
    attr_reader :campaign_class, :heading, :short_description, :link, :link_text

    def initialize(content:)
      @campaign_class = content[:campaign_class]
      @heading = content[:heading]
      @short_description = content[:short_description]
      @link = content[:link]
      @link_text = link.blank? ? nil : content[:link_text]
    end

    def valid?
      campaign_class.present? && heading.present?
    end

    class << self
      def for_path(path)
        content = get_content
        return nil if content.blank?

        candidate_banner = EmergencyBanner.new(content:)
        return nil unless candidate_banner.valid?
        return nil if URI.parse(candidate_banner.link).path == path

        candidate_banner
      end

    private

      def client
        @client ||= Redis.new(timeout: 0.1)
      end

      def get_content
        client.hgetall("emergency_banner").try(:symbolize_keys)
      rescue StandardError => e
        ::GovukError.notify(e)
        nil
      end
    end
  end
end
