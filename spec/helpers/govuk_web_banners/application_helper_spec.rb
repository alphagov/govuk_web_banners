RSpec.describe GovukWebBanners::ApplicationHelper do
  let(:request) { double("request", path: "/some-path") }

  describe "#recruitment_banner_present?" do
    it "returns false if no banner is present on the path" do
      expect(recruitment_banner_present?).to be false
    end
  end
end
