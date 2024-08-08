describe "govuk_web_banners/_recruitment_banner" do
  before do
    original_path = Rails.root.join(GovukWebBanners.root, "config/govuk_web_banners/recruitment_banners.yml")
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
  end

  context "with no banners present" do
    let!(:replacement_file) { YAML.load_file(Rails.root.join(GovukWebBanners.root, "spec/fixtures/empty_recruitment_banners.yml")) }

    it "displays nothing" do
      render

      expect(rendered).to eq("")
    end
  end
end
