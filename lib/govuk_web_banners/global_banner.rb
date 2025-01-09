module GovukWebBanners
  class GlobalBanner
    BANNER_CONFIG_FILE = "../../config/govuk_web_banners/global_banners.yml".freeze

    def self.for_path(path)
      return nil if active_banners.empty?

      active_banners.first.exclude_paths.include?(path) ? nil : active_banners.first
    end

    def self.active_banners
      all_banners.select(&:active?)
    end

    def self.all_banners
      global_banners_file_path = Rails.root.join(__dir__, BANNER_CONFIG_FILE)
      global_banners_data = YAML.load_file(global_banners_file_path)
      global_banners_data["global_banners"].map { |attributes| GlobalBanner.new(attributes:) }
    end

    attr_reader :name, :items, :start_date, :end_date, :show_arrows, :permanent, :exclude_paths

    def initialize(attributes:)
      @name = attributes["name"]
      @items = (attributes["items"] || []).map { Item.new(attributes: _1) }

      @start_date = attributes["start_date"] ? Time.parse(attributes["start_date"]) : Time.at(0)
      @end_date = attributes["end_date"] ? Time.parse(attributes["end_date"]) : Time.now + 10.years
      @show_arrows = attributes["show_arrows"] == "true"
      @permanent = attributes["permanent"] == "true"
      @exclude_paths = attributes["exclude_paths"] || []
      @exclude_paths += items.collect(&:title_path)
    end

    # NB: .between? is inclusive. To make it exclude the end date, we set the end range as
    #     1 second earlier.
    def active?
      Time.zone.now.between?(start_date, end_date - 1.second)
    end

    class Item
      attr_reader :title, :title_path, :info_text

      def initialize(attributes:)
        @title = attributes["title"]
        @title_path = attributes["title_path"]
        @info_text = attributes["info_text"]
      end
    end
  end
end
