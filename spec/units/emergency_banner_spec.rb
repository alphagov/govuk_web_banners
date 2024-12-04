RSpec.describe GovukWebBanners::EmergencyBanner do
  context "with the emergency banner active" do
    before do
      allow_any_instance_of(Redis).to receive(:hgetall).with("emergency_banner").and_return(
        heading: "Emergency!",
        campaign_class: "notable-death",
      )
    end

    describe ".banner" do
      it "returns a banner" do
        expect(described_class.banner).to be_instance_of(described_class)
      end
    end

    describe "#active?" do
      it "returns true" do
        expect(described_class.banner.active?).to be true
      end
    end
  end

  context "with the emergency banner inactive" do
    before do
      allow_any_instance_of(Redis).to receive(:hgetall).with("emergency_banner").and_return(
        heading: "",
        campaign_class: "",
      )
    end

    describe ".banner" do
      it "returns a banner" do
        expect(described_class.banner).to be_instance_of(described_class)
      end
    end

    describe "#active?" do
      it "returns false" do
        expect(described_class.banner.active?).to be false
      end
    end
  end

  context "if the call to Redis fails" do
    before do
      allow_any_instance_of(Redis).to receive(:hgetall).with("emergency_banner").and_raise(StandardError)
    end

    describe ".banner" do
      it "returns a banner" do
        expect(described_class.banner).to be_instance_of(described_class)
      end
    end

    describe "#active?" do
      it "returns false" do
        expect(described_class.banner.active?).to be false
      end
    end
  end
end
