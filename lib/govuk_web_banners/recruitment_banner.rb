module GovukWebBanners
  class RecruitmentBanner
    CONFIG_FILE_PATH = "../../config/govuk_web_banners/recruitment_banners.yml".freeze

    def self.for_path(path)
      all_banners.find do |banner|
        return banner if banner.page_paths.include?(path)
      end
    end

    def self.all_banners
      recruitment_banners_data = YAML.load_file(Rails.root.join(__dir__, CONFIG_FILE_PATH))

      recruitment_banners_data["banners"].map { |attributes| RecruitmentBanner.new(attributes:) }
    end

    attr_reader :name, :suggestion_text, :suggestion_link_text, :survey_url, :page_paths

    def initialize(attributes:)
      @name = attributes["name"]
      @suggestion_text = attributes["suggestion_text"]
      @suggestion_link_text = attributes["suggestion_link_text"]
      @survey_url = attributes["survey_url"]
      @page_paths = attributes["page_paths"]
    end

    def valid?
      suggestion_text.present? && suggestion_link_text.present? && survey_url.present? && page_paths.present?
    end
  end
end