RSpec.describe GovukWebBanners::ApplicationHelper do
  before do
    original_path = Rails.root.join(__dir__, "../../../config/govuk_web_banners/recruitment_banners.yml")
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
  end

  describe "#recruitment_banner" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/active_recruitment_banners.yml"))
    end

    context "with no banner present on the path" do
      let(:request) { double("request", path: "/some-path") }

      it "returns nil" do
        expect(recruitment_banner).to be_nil
      end
    end

    context "with a banner present on the path" do
      let(:request) { double("request", path: "/foreign-travel-advice") }

      it "returns the banner" do
        expect(recruitment_banner).to be_instance_of(RecruitmentBanner)
      end
    end
  end
end
