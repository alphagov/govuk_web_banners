module GovukWebBanners
  class GlobalBanner
    BANNER_CONFIG_FILE = "../../config/govuk_web_banners/global_banners.yml".freeze

    def self.for_path(path)
      active_banners.reject { |b| b.exclude_paths.include?(path) }
    end

    def self.active_banners
      all_banners.select(&:active?)
    end

    def self.all_banners
      global_banners_file_path = Rails.root.join(__dir__, BANNER_CONFIG_FILE)
      global_banners_data = YAML.load_file(global_banners_file_path)
      global_banners_data["global_banners"].map { |attributes| GlobalBanner.new(attributes:) }
    end

    attr_reader :name, :title, :title_href, :text, :start_date, :end_date, :show_arrows, :always_visible, :exclude_paths

    def initialize(attributes:)
      @name = attributes["name"]

      @title = attributes["title"]
      @title_href = attributes["title_href"]
      @text = attributes["text"]

      @start_date = attributes["start_date"] ? ActiveSupport::TimeZone[GovukWebBanners::TIME_ZONE].parse(attributes["start_date"]) : nil
      @end_date = attributes["end_date"] ? ActiveSupport::TimeZone[GovukWebBanners::TIME_ZONE].parse(attributes["end_date"]) : Time.now + 10.years
      @show_arrows = attributes["show_arrows"] == "true"
      @always_visible = attributes["always_visible"] == "true"
      @exclude_paths = attributes["exclude_paths"] || []
      @exclude_paths << title_href if title_href&.start_with?("/")
    end

    # NB: .between? is inclusive. To make it exclude the end date, we set the end range as
    #     1 second earlier.
    def active?
      Time.zone.now.between?(start_date, end_date - 1.second)
    end

    def version
      start_date.getutc.to_i
    end
  end
end
