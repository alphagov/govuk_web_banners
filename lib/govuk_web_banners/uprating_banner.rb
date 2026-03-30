module GovukWebBanners
  class UpratingBanner
    BANNER_CONFIG_FILE = "../../config/govuk_web_banners/uprating_banners.yml".freeze

    def self.for_path(path)
      active_banners.find do |banner|
        return banner if banner.page_paths.include?(path)
      end
    end

    def self.active_banners
      all_banners.select(&:active?)
    end

    def self.all_banners
      uprating_banners_urls_file_path = Rails.root.join(__dir__, BANNER_CONFIG_FILE)
      uprating_banners_data = YAML.load_file(uprating_banners_urls_file_path)
      uprating_banners_data["banners"].map { |attributes| UpratingBanner.new(attributes:) }
    end

    attr_reader :name, :text, :page_paths, :start_date, :end_date

    def initialize(attributes:)
      @name = attributes["name"]
      @text = attributes["text"]
      @page_paths = attributes["page_paths"]
      @start_date = attributes["start_date"] ? ActiveSupport::TimeZone[GovukWebBanners::TIME_ZONE].parse(attributes["start_date"]) : Time.at(0)
      @end_date = attributes["end_date"] ? ActiveSupport::TimeZone[GovukWebBanners::TIME_ZONE].parse(attributes["end_date"]) : Time.now + 10.years
    end

    # NB: .between? is inclusive. To make it exclude the end date, we set the end range as
    #     1 second earlier.
    def active?
      Time.zone.now.between?(start_date, end_date - 1.second)
    end
  end
end
