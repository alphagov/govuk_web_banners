module GovukWebBanners
  class RecruitmentBanner
    BANNER_CONFIG_FILE = "../../config/govuk_web_banners/recruitment_banners.yml".freeze

    def self.for_path(path)
      active_banners.find do |banner|
        return banner if banner.page_paths.include?(path)
      end
    end

    def self.active_banners
      all_banners.select(&:active?)
    end

    def self.all_banners
      recruitment_banners_urls_file_path = Rails.root.join(__dir__, BANNER_CONFIG_FILE)
      recruitment_banners_data = YAML.load_file(recruitment_banners_urls_file_path)
      recruitment_banners_data["banners"].map { |attributes| RecruitmentBanner.new(attributes:) }
    end

    attr_reader :name, :suggestion_text, :suggestion_link_text, :survey_url, :page_paths, :start_date, :end_date, :image

    def initialize(attributes:)
      @name = attributes["name"]
      @suggestion_text = attributes["suggestion_text"]
      @suggestion_link_text = attributes["suggestion_link_text"]
      @survey_url = attributes["survey_url"]
      @page_paths = attributes["page_paths"]
      @start_date = attributes["start_date"] ? ActiveSupport::TimeZone[GovukWebBanners::TIME_ZONE].parse(attributes["start_date"]) : Time.at(0)
      @end_date = attributes["end_date"] ? ActiveSupport::TimeZone[GovukWebBanners::TIME_ZONE].parse(attributes["end_date"]) : Time.now + 10.years
      @image = attributes["image"]
    end

    # NB: .between? is inclusive. To make it exclude the end date, we set the end range as
    #     1 second earlier.
    def active?
      Time.zone.now.between?(start_date, end_date - 1.second)
    end
  end
end
