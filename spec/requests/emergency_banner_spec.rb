RSpec.describe "Emergency Banners" do
  context "getting a path with the banner partial" do
    context "with the emergency banner active" do
      before do
        allow_any_instance_of(Redis).to receive(:hgetall).with("emergency_banner").and_return(
          heading: "Emergency!",
          campaign_class: "notable-death",
        )
      end

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
      before do
        allow_any_instance_of(Redis).to receive(:hgetall).with("emergency_banner").and_return({})
      end

      it "does not show a banner in the page" do
        get "/emergency"

        expect(response.body).not_to include("Emergency!")
      end
    end
  end
end
