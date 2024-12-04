RSpec.describe GovukWebBanners::EmergencyBanner do
  let(:redis_client) { double(hgetall: {}) }
  subject(:emergency_banner) { GovukWebBanners::EmergencyBanner.new(redis_client:) }

  describe "caching" do
    context "with a Rails cache" do
      it "caches calls to the redis client for one minute" do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
        Rails.cache.clear

        GovukWebBanners::EmergencyBanner.new(redis_client:)
        GovukWebBanners::EmergencyBanner.new(redis_client:)

        expect(redis_client).to have_received(:hgetall).once

        travel_to(Time.now + 61.seconds)

        GovukWebBanners::EmergencyBanner.new(redis_client:)
        expect(redis_client).to have_received(:hgetall).twice

        travel_back
      end
    end
  end

  describe "#active?" do
    context "with the emergency banner inactive" do
      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end

    context "with the emergency banner active" do
      let(:redis_client) { double(hgetall: { heading: "Emergency!", campaign_class: "notable-death" }) }

      it "returns true" do
        expect(emergency_banner.active?).to be true
      end
    end

    context "if the call to Redis fails" do
      before do
        allow(redis_client).to receive(:hgetall).with("emergency_banner").and_raise(StandardError)
      end

      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end
  end
end
