RSpec.describe GovukWebBanners::EmergencyBanner do
  describe ".for_path" do
    context "when the client cannot talk to the Redis cluster" do
      before do
        allow_any_instance_of(Redis).to receive(:hgetall).and_raise(StandardError)
      end

      it "returns nil" do
        expect(described_class.for_path("/some-page")).to be nil
      end
    end

    context "when there is no current emergency banner set in Redis" do
      it "returns nil" do
        expect(described_class.for_path("/some-page")).to be nil
      end
    end

    context "when there is an invalid current emergency banner set in Redis" do
      before { set_invalid_emergency_banner }

      it "returns nil" do
        expect(described_class.for_path("/some-page")).to be_nil
      end
    end

    context "when there is a valid current emergency banner set in Redis" do
      before { set_valid_emergency_banner }

      it "returns a valid banner for general paths" do
        expect(described_class.for_path("/some-page")).to be_instance_of(described_class)
      end

      it "returns nil if the path matches the path in the emergency banner link" do
        expect(described_class.for_path("/emergency")).to be_nil
      end
    end
  end
end
