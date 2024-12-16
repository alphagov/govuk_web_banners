RSpec.describe "Emergency Banners" do
  before do
    Rails.application.config.emergency_banner_redis_client = redis_client
  end

  context "when getting a path with the banner partial" do
    context "with the emergency banner active" do
      let(:redis_client) { instance_double(Redis, hgetall: { heading: "Emergency!", campaign_class: "notable-death" }) }

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

    context "with the emergency banner inactive" do
      let(:redis_client) { instance_double(Redis, hgetall: {}) }

      it "does not show a banner in the page" do
        get "/emergency"

        expect(response.body).not_to include("Emergency!")
      end
    end
  end
end
