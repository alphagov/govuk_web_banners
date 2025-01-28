RSpec.describe GovukWebBanners::GlobalBanner do
  let(:fixtures_dir) { Rails.root.join(__dir__, "../../fixtures/") }

  before do
    original_path = Rails.root.join(__dir__, "../", described_class::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
  end

  describe ".for_path" do
    context "with banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(fixtures_dir, "active_global_banners.yml"))
      end

      it "returns array with the banner for a random path" do
        expect(described_class.for_path("/foreign-travel-advice").count).to eq(1)
        expect(described_class.for_path("/foreign-travel-advice").first).to be_instance_of(described_class)
      end

      it "returns empty array the path the banner links to" do
        expect(described_class.for_path("/global-linked-to")).to be_empty
      end

      it "returns empty array for a path in excluded_paths" do
        expect(described_class.for_path("/global-related-to")).to be_empty
      end
    end

    context "with timed global banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(fixtures_dir, "timed_global_banners.yml"))
      end

      after { travel_back }

      context "but before timed global banners are active" do
        before { travel_to Time.local(2024, 12, 31) }

        it "finds only banners with no start time" do
          expect(described_class.for_path("/")).to be_empty
        end
      end

      context "and on the day january banner becomes active" do
        before { travel_to Time.local(2025, 1, 12) }

        it "finds one banner active on that date" do
          expect(described_class.for_path("/").count).to eq(1)
          expect(described_class.for_path("/").first.name).to eq("Banner jan-mar")
          expect(described_class.for_path("/").first.version).to eq(1_736_640_000)
        end
      end

      context "and on the day feb banner becomes active" do
        before { travel_to Time.local(2025, 2, 12) }

        it "finds both banners active on that date" do
          expect(described_class.for_path("/").count).to eq(2)
          expect(described_class.for_path("/").first.name).to eq("Banner jan-mar")
          expect(described_class.for_path("/").first.version).to eq(1_736_640_000)
          expect(described_class.for_path("/").second.name).to eq("Banner feb-apr")
          expect(described_class.for_path("/").second.version).to eq(1_739_318_400)
        end
      end

      context "and on the day jan banner becomes inactive" do
        before { travel_to Time.local(2025, 3, 12) }

        it "finds both banners active on that date" do
          expect(described_class.for_path("/").count).to eq(1)
          expect(described_class.for_path("/").first.name).to eq("Banner feb-apr")
          expect(described_class.for_path("/").first.version).to eq(1_739_318_400)
        end
      end

      context "and on the day feb banner swaps to apr banner" do
        before { travel_to Time.local(2025, 4, 12) }

        it "finds both banners active on that date" do
          expect(described_class.for_path("/").count).to eq(1)
          expect(described_class.for_path("/").first.name).to eq("Banner apr-may")
          expect(described_class.for_path("/").first.version).to eq(1_744_412_400)
        end
      end

      context "but after all timed banners end" do
        before { travel_to Time.local(2025, 5, 12) }

        it "finds no banners active" do
          expect(described_class.for_path("/")).to be_empty
        end
      end
    end
  end
end
