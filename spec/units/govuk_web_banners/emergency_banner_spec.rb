RSpec.describe GovukWebBanners::EmergencyBanner do
  subject(:emergency_banner) { described_class.new }

  before { stub_const("GovukWebBanners::EmergencyBanner::CONFIG_LOCATION", config_file) }

  describe "#active?" do
    context "with the emergency banner inactive" do
      let(:config_file) { "spec/fixtures/inactive_emergency_banner.yml" }

      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end

    context "with the emergency banner active" do
      let(:config_file) { "spec/fixtures/active_emergency_banner.yml" }

      it "returns true" do
        expect(emergency_banner.active?).to be true
      end
    end

    context "when the config file is missing" do
      let(:config_file) { "spec/fixtures/missing_emergency_banner.yml" }

      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end
  end
end
