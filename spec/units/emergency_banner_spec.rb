RSpec.describe GovukWebBanners::EmergencyBanner do
  subject(:emergency_banner) { GovukWebBanners::EmergencyBanner.new }

  before do
    Rails.application.config.emergency_banner_redis_client = double(hgetall: {})
  end

  describe "caching" do
    context "with a Rails cache" do
      it "caches calls to the redis client for one minute" do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
        Rails.cache.clear

        GovukWebBanners::EmergencyBanner.new
        GovukWebBanners::EmergencyBanner.new

        expect(Rails.application.config.emergency_banner_redis_client).to have_received(:hgetall).once

        travel_to(Time.now + 61.seconds)

        GovukWebBanners::EmergencyBanner.new
        expect(Rails.application.config.emergency_banner_redis_client).to have_received(:hgetall).twice

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
      before do
        Rails.application.config.emergency_banner_redis_client = double(hgetall: { heading: "Emergency!", campaign_class: "notable-death" })
      end

      it "returns true" do
        expect(emergency_banner.active?).to be true
      end
    end

    context "if the call to Redis fails" do
      before do
        redis_client = double
        allow(redis_client).to receive(:hgetall).with("emergency_banner").and_raise(StandardError)
        Rails.application.config.emergency_banner_redis_client = redis_client
      end

      it "returns false" do
        expect(emergency_banner.active?).to be false
      end
    end
  end
end
