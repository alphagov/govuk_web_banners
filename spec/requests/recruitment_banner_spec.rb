RSpec.describe "Recruitment Banners" do
  before do
    original_path = Rails.root.join(__dir__, GovukWebBanners::RecruitmentBanner::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
  end

  context "getting a path with the banner partial" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/requests_banners.yml"))
    end

    context "with an active banner" do
      it "shows a banner in the page" do
        get "/page-with-banners"

        expect(response.body).to include("This banner appears at /pages-with-banners!")
      end
    end

    context "with no active banner" do
      it "does not show a banner in the page" do
        get "/page-with-no-banners"

        expect(response.body).not_to include("This banner appears at /pages-with-banners!")
      end
    end
  end
end
