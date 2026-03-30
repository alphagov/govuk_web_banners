RSpec.describe "Uprating Banners" do
  before do
    original_path = Rails.root.join(
      __dir__,
      GovukWebBanners::UpratingBanner::BANNER_CONFIG_FILE,
    )

    allow(YAML).to receive(:load_file)
      .with(original_path)
      .and_return(replacement_file)
  end

  context "when visiting a path with the banner partial" do
    let(:replacement_file) do
      YAML.unsafe_load_file(
        Rails.root.join(__dir__, "../../spec/fixtures/requests_uprating_banners.yml"),
      )
    end

    context "with an active banner" do
      it "shows a banner in the page" do
        get "/uprating-with-banners"

        expect(response.body).to include(
          "This banner appears at /uprating-with-banners!",
        )
      end
    end

    context "with no active banner" do
      it "does not show a banner in the page" do
        get "/uprating-with-no-banners"

        expect(response.body).not_to include(
          "This banner appears at /uprating-with-banners!",
        )
      end
    end
  end
end
