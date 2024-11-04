RSpec.describe RecruitmentBanner do
  context "current configuration" do
    it "contains the root banners: key (or banners: [] if there are no entries)" do
      expect { described_class.all_banners }.not_to raise_error
    end

    it "does not contain invalid banners" do
      expect(described_class.all_banners.all?(&:valid?)).to eq(true)
    end

    it "does not contain banners pointing to the same path" do
      all_paths = []
      described_class.all_banners.each { |banner| all_paths << banner.page_paths }

      expect(all_paths.uniq.count).to eq(all_paths.count)
    end
  end

  context "hypothetical configurations" do
    before do
      original_path = Rails.root.join(__dir__, "../../config/govuk_web_banners/recruitment_banners.yml")
      allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)
    end

    context "with banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/active_recruitment_banners.yml"))
      end

      describe ".for_path?" do
        it "returns banner that includes the path" do
          expect(described_class.for_path("/foreign-travel-advice")).to be_instance_of(RecruitmentBanner)
        end

        it "returns nil for a path without a banner" do
          expect(described_class.for_path("/foreign-climbing-advice")).to be_nil
        end
      end

      describe ".all_banners" do
        it "returns an array with " do
          expect(described_class.all_banners.count).to eq(2)
        end
      end
    end

    context "with broken banners" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/broken_recruitment_banners.yml"))
      end

      describe ".all_banners" do
        it "confirms invalid banners exist" do
          expect(described_class.all_banners.none?(&:valid?)).to eq(true)
        end
      end
    end

    context "with an empty file" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../spec/fixtures/empty_recruitment_banners.yml"))
      end

      describe ".all_banners" do
        it "raises an error" do
          expect { described_class.all_banners }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
