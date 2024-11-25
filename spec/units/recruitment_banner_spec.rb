RSpec.describe GovukWebBanners::RecruitmentBanner do
  before do
    original_path = Rails.root.join(__dir__, described_class::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
  end

  describe ".for_path" do
    context "with banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/active_recruitment_banners.yml"))
      end

      it "returns banner that includes the path" do
        expect(described_class.for_path("/foreign-travel-advice")).to be_instance_of(described_class)
      end

      it "returns nil for a path without a banner" do
        expect(described_class.for_path("/foreign-climbing-advice")).to be_nil
      end
    end

    context "with timed banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/timed_recruitment_banners.yml"))
      end

      after { travel_back }

      context "Before timed banners are active" do
        before { travel_to Time.local(2024, 12, 31) }

        it "finds only banners with no start time" do
          expect(described_class.for_path("/page-1")).to be_nil
          expect(described_class.for_path("/page-2")).to be_instance_of(described_class)
          expect(described_class.for_path("/page-3")).to be_nil
          expect(described_class.for_path("/page-4")).to be_instance_of(described_class)
        end
      end

      context "The day banners 1 and 3 become active and banner 2 ends" do
        before { travel_to Time.local(2025, 1, 1) }

        it "finds only banners active on that date" do
          expect(described_class.for_path("/page-1")).to be_instance_of(described_class)
          expect(described_class.for_path("/page-2")).to be_nil
          expect(described_class.for_path("/page-3")).to be_instance_of(described_class)
          expect(described_class.for_path("/page-4")).to be_instance_of(described_class)
        end

        it "finds the first banner for /page-3" do
          expect(described_class.for_path("/page-3").name).to eq("Banner with start and end date")
        end
      end

      context "The day the page-3 banner swaps" do
        before { travel_to Time.local(2025, 2, 1) }

        it "finds only banners active on that date" do
          expect(described_class.for_path("/page-1")).to be_instance_of(described_class)
          expect(described_class.for_path("/page-2")).to be_nil
          expect(described_class.for_path("/page-3")).to be_instance_of(described_class)
          expect(described_class.for_path("/page-4")).to be_instance_of(described_class)
        end

        it "finds the second banner for /page-3" do
          expect(described_class.for_path("/page-3").name).to eq("Banner with start and end date abutting previous banner")
        end
      end

      context "After all timed banners end" do
        before { travel_to Time.local(2025, 3, 1) }

        it "finds only banners active on that date" do
          expect(described_class.for_path("/page-1")).to be_instance_of(described_class)
          expect(described_class.for_path("/page-2")).to be_nil
          expect(described_class.for_path("/page-3")).to be_nil
          expect(described_class.for_path("/page-4")).to be_instance_of(described_class)
        end
      end
    end
  end
end
