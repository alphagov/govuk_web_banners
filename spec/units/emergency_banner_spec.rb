RSpec.describe GovukWebBanners::EmergencyBanner do
  describe ".banner" do
    context "when the client cannot talk to the Redis cluster" do
      before do
        allow_any_instance_of(Redis).to receive(:hgetall).and_raise(StandardError)
      end

      it "returns nil" do
        expect(described_class.banner).to be nil
      end
    end

    context "when there is no current emergency banner set in Redis" do
      it "returns nil" do
        expect(described_class.banner).to be nil
      end
    end

    context "when there is an invalid current emergency banner set in Redis" do
      before { set_invalid_emergency_banner }

      it "returns nil" do
        expect(described_class.banner).to be_nil
      end
    end

    context "when there is a valid current emergency banner set in Redis" do
      before { set_valid_emergency_banner }

      it "returns a valid banner" do
        expect(described_class.banner).to be_instance_of(described_class)
      end
    end
  end
end
