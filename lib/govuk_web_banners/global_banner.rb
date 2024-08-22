module GovukWebBanners
  class GlobalBanner
    CONFIG_FILE_PATH = "../../config/govuk_web_banners/global_banner.yml".freeze

    def self.for_path(_path)
      all_configurations.find do |banner|
        return banner if banner.active_now?
      end
    end

    def self.all_configurations
      global_banner_data = YAML.load_file(Rails.root.join(__dir__, CONFIG_FILE_PATH))

      global_banner_data["global_banner"].map { |attributes| GlobalBanner.new(attributes:) }
    end

    attr_reader :title, :title_href, :link_text, :starts_at, :ends_at

    def initialize(attributes:)
      @title = attributes["title"]
      @title_href = attributes["title_href"]
      @link_text = attributes["link_text"]
      @starts_at = Time.parse(attributes["starts_at"])
      @ends_at = Time.parse(attributes["starts_at"])
    end

    def valid?
      title.present? && title_href.present? && link_text.present?
    end

    def active_now?
    end
  end
end
