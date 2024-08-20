RSpec.describe GovukWebBanners::BannersHelper do
  describe "#emergency_banner" do
    let(:request) { double("request", path: "/some-path") }

    context "with no emergency banner set" do
      it "returns nil" do
        expect(emergency_banner).to be_nil
      end
    end

    context "with an emergency banner set " do
      before { set_valid_emergency_banner }

      it "returns the banner" do
        expect(emergency_banner).to be_instance_of(GovukWebBanners::EmergencyBanner)
      end

      context "at the path the emergency banner points to" do
        let(:request) { double("request", path: "/emergency") }

        it "returns nil" do
          expect(emergency_banner).to be_nil
        end
      end
    end
  end

  describe "#recruitment_banner" do
    before do
      replacement_file = YAML.load_file(Rails.root.join(GovukWebBanners.root, "spec/fixtures/active_recruitment_banners.yml"))
      original_path = Rails.root.join(GovukWebBanners.root, "config/govuk_web_banners/recruitment_banners.yml")
      allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
    end

    context "with no banner present on the path" do
      let(:request) { double("request", path: "/some-path") }

      it "returns nil if no banner is present on the path" do
        expect(recruitment_banner).to be_nil
      end
    end

    context "with a banner present on the path" do
      let(:request) { double("request", path: "/foreign-travel-advice") }

      it "returns the banner if a banner is present on the path" do
        expect(recruitment_banner).to be_instance_of(GovukWebBanners::RecruitmentBanner)
      end

      it "returns nil if a banner is present, but so is a valid emergency banner" do
        set_valid_emergency_banner

        expect(recruitment_banner).to be_nil
      end
    end
  end
end
