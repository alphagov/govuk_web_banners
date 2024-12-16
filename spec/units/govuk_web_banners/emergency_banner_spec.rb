RSpec.describe GovukWebBanners::EmergencyBanner do
  let(:redis_client) { instance_double(Redis, hgetall: {}) }

  before do
    Rails.application.config.emergency_banner_redis_client = redis_client
  end

  describe "caching" do
    context "with a Rails cache" do
      it "caches calls to the redis client for one minute" do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
        Rails.cache.clear

        described_class.new
        described_class.new

        expect(redis_client).to have_received(:hgetall).once

        travel_to(Time.now + 61.seconds)

        described_class.new
        expect(redis_client).to have_received(:hgetall).twice

        travel_back
      end
    end
  end

  describe "#active?" do
    subject(:emergency_banner) { described_class.new }

    context "with the emergency banner inactive" do
      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end

    context "with the emergency banner active" do
      let(:redis_client) { instance_double(Redis, hgetall: { heading: "Emergency!", campaign_class: "notable-death" }) }

      it "returns true" do
        expect(emergency_banner.active?).to be true
      end
    end

    context "with a failing call to Redis fails" do
      before do
        allow(redis_client).to receive(:hgetall).with("emergency_banner").and_raise(StandardError)
      end

      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end
  end
end
