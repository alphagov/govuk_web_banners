RSpec.describe GovukWebBanners::GlobalBanner do
  context "current configuration" do
    it "has a global_banner key" do
      data = YAML.load_file(Rails.root.join(__dir__, described_class::CONFIG_FILE_PATH))

      expect(data).to have_key("global_banner")
    end

    it "does not contain invalid banner configs" do
      expect(described_class.all_banners.all?(&:valid?)).to eq(true)
    end

    it "does not contain banner configs that overlap in time" do
      described_class.all_banners.each do |banner1|
        described_class.all_banners.each do |banner2|
          # EXPECT THAT THE RANGES DON'T OVERLAP
        end
      end
    end
  end

  context "hypothetical configurations" do
    before do
      original_path = Rails.root.join(__dir__, "../../config/govuk_web_banners/global_banners.yml")
      allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
    end

    context "with banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/active_global_banners.yml"))
      end

      describe ".for_path?" do
        it "returns banner that includes the path" do
          expect(described_class.for_path("/foreign-travel-advice")).to be_instance_of(described_class)
        end

        it "returns nil for a path without a banner" do
          expect(described_class.for_path("/foreign-climbing-advice")).to be_nil
        end
      end

      describe ".all_configurations" do
        it "returns an array with " do
          expect(described_class.all_configurations.count).to eq(2)
        end
      end
    end

    context "with broken banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(GovukWebBanners.root, "spec/fixtures/broken_global_banners.yml"))
      end

      describe ".all_banners" do
        it "confirms invalid banners exist" do
          expect(described_class.all_banners.none?(&:valid?)).to eq(true)
        end
      end
    end
  end
end
