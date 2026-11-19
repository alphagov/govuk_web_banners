RSpec.describe GovukWebBanners::EmergencyBanner do
  subject(:emergency_banner) { described_class.new }

  before { stub_const("GovukWebBanners::EmergencyBanner::CONFIG_LOCATION", config_file) }

  describe "#deployed?" do
    context "with the emergency banner undeployed" do
      let(:config_file) { "spec/fixtures/undeployed_emergency_banner.yml" }

      it "returns false" do
        expect(emergency_banner.deployed?).to be false
      end
    end

    context "with the emergency banner deployed" do
      let(:config_file) { "spec/fixtures/deployed_emergency_banner.yml" }

      it "returns true" do
        expect(emergency_banner.deployed?).to be true
      end
    end

    context "when the config file is missing" do
      let(:config_file) { "spec/fixtures/missing_emergency_banner.yml" }

      it "returns false" do
        expect(emergency_banner.deployed?).to be false
      end
    end
  end
end
