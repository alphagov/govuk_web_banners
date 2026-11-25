RSpec.describe "Emergency Banners" do
  before do
    stub_const("GovukWebBanners::EmergencyBanner::CONFIG_LOCATION", config_file)
    Rails.application.config.emergency_banner = GovukWebBanners::EmergencyBanner.new
  end

  context "when getting a path with the banner partial" do
    context "with the emergency banner deployed" do
      let(:config_file) { "spec/fixtures/deployed_emergency_banner.yml" }

      it "shows a banner in the page" do
        get "/emergency"

        expect(response.body).to include("Emergency!")
        expect(response.body).not_to include("gem-c-emergency-banner__heading--homepage")
      end

      it "shows the homepage varient banner in the homepage" do
        get "/"

        expect(response.body).to include("Emergency!")
        expect(response.body).to include("gem-c-emergency-banner__heading--homepage")
      end
    end

    context "with the emergency banner undeployed" do
      let(:config_file) { "spec/fixtures/undeployed_emergency_banner.yml" }

      it "does not show a banner in the page" do
        get "/emergency"

        expect(response.body).not_to include("Emergency!")
      end
    end
  end
end
