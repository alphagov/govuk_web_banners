RSpec.describe GovukWebBanners::ApplicationHelper do
  let(:request) { double("request", path: "/some-path") }

  describe "#recruitment_banner" do
    it "returns nil if no banner is present on the path" do
      expect(recruitment_banner).to be_nil
    end
  end
end
