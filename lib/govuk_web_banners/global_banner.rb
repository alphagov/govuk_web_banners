module GovukWebBanners
  class GlobalBanner
    BANNER_CONFIG_FILE = "../../config/govuk_web_banners/global_banners.yml".freeze

    def self.for_path(path)
      return nil if active_banners.empty?

      path != active_banners.first.href ? active_banners.first : nil
    end

    def self.active_banners
      all_banners.select(&:active?)
    end

    def self.all_banners
      global_banners_file_path = Rails.root.join(__dir__, BANNER_CONFIG_FILE)
      global_banners_data = YAML.load_file(global_banners_file_path)
      global_banners_data["global_banners"].map { |attributes| GlobalBanner.new(attributes:) }
    end

    attr_reader :name, :title, :title_href, :text, :text_href, :start_date, :end_date

    def initialize(attributes:)
      @name = attributes["name"]
      @title = attributes["title"]
      @title_href = attributes["title_href"]
      @text = attributes["text"]
      @text_href = attributes["text_href"]
      @start_date = attributes["start_date"] ? Time.parse(attributes["start_date"]) : Time.at(0)
      @end_date = attributes["end_date"] ? Time.parse(attributes["end_date"]) : Time.now + 10.years
    end

    def href
      title_href || text_href
    end

    # NB: .between? is inclusive. To make it exclude the end date, we set the end range as
    #     1 second earlier.
    def active?
      Time.zone.now.between?(start_date, end_date - 1.second)
    end
  end
end
