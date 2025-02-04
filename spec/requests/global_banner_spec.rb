RSpec.describe "Global Banners" do
  before do
    original_path = Rails.root.join(__dir__, GovukWebBanners::GlobalBanner::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
  end

  context "when visiting a page which includes the global banner partial" do
    context "and the a banner is active" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/active_global_banners.yml"))
      end

      it "shows the banner on the page" do
        get "/global"

        expect(response.body).to include("Here is a global message")
      end

      it "does not show the banner on the page the banner links to" do
        get "/global-linked-to"

        expect(response.body).not_to include("Here is a global message")
      end

      it "does not show the banner on a page in the except_paths list" do
        get "/global-related-to"

        expect(response.body).not_to include("Here is a global message")
      end
    end

    context "but no banner is active" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/empty_global_banners.yml"))
      end

      it "does not show the banner on the page" do
        get "/global"

        expect(response.body).not_to include("Here is a global message")
      end
    end
  end
end
