require "govuk_web_banners/validators/base"
require "govuk_web_banners/validators/global_banner"

RSpec.describe GovukWebBanners::Validators::GlobalBanner do
  subject(:validator) { described_class.new(GovukWebBanners::GlobalBanner.all_banners) }

  let(:fixtures_dir) { Rails.root.join(__dir__, "../../../../spec/fixtures/") }

  before do
    original_path = Rails.root.join(__dir__, "../../", GovukWebBanners::GlobalBanner::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)

    stub_request(:get, %r{\Ahttps://www\.gov\.uk/api/content/.*})
  end

  context "with valid banners" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "active_global_banners.yml"))
    end

    describe ".valid?" do
      it "returns true" do
        expect(validator.valid?).to be true
      end
    end

    describe "errors attribute" do
      it "returns an empty array" do
        expect(validator.errors).to be_empty
      end
    end
  end

  context "with invalid banners" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "invalid_global_banners.yml"))
    end

    describe ".valid?" do
      it "returns false" do
        expect(validator.valid?).to be false
      end
    end

    describe "errors attribute" do
      it "returns the relevant errors" do
        expect(validator.errors["Banner without an items list"]).to eq(["must have at least one item in the items list"])
        expect(validator.errors["Banner with an empty items list"]).to eq(["must have at least one item in the items list"])
        expect(validator.errors["Banner without title_path"]).to eq(["item 0 is missing a title_path"])
        expect(validator.errors["Banner without title"]).to eq(["item 0 is missing a title"])
        expect(validator.errors["Banner without info_text"]).to eq(["item 0 is missing an info_text"])
        expect(validator.errors["Invalid title_path"]).to eq([
          "item 0 title_path hello should start with a /",
          "exclude_path hello should start with a /",
        ])
        expect(validator.errors["Dates inverted"]).to eq(["start_date is after end_date"])
      end
    end
  end

  context "with a banner that has expired" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "expired_global_banners.yml"))
    end

    before { travel_to Time.local(2024, 1, 2) }
    after { travel_back }

    describe ".valid?" do
      it "returns true" do
        expect(validator.valid?).to be true
      end
    end

    describe ".warnings?" do
      it "returns true" do
        expect(validator.warnings?).to be true
      end
    end

    describe "warnings attribute" do
      it "returns the relevant warnings" do
        expect(validator.warnings).to eq({ "Expired Banner" => ["is expired"] })
      end
    end
  end

  context "with banners that are active at the same time" do
    context "when they are active at the same time" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(fixtures_dir, "same_time_global_banners.yml"))
      end

      describe ".valid?" do
        it "returns false" do
          expect(validator.valid?).to be false
        end
      end

      describe "errors attribute" do
        it "returns the relevant errors" do
          expect(validator.errors["Banner feb-apr"]).to eq(["is active at the same time as Banner jan-mar"])
          expect(validator.errors["Banner jan-mar"]).to eq(["is active at the same time as Banner feb-apr"])
        end
      end
    end
  end

  context "with a path that doesn't exist on the live site" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "active_global_banners.yml"))
    end

    before do
      stub_request(:get, %r{\Ahttps://www\.gov\.uk/api/content/global-linked-to}).to_return(status: 404)
    end

    describe ".valid?" do
      it "returns true" do
        expect(validator.valid?).to be true
      end
    end

    describe ".warnings?" do
      it "returns true" do
        expect(validator.warnings?).to be true
      end
    end

    describe "warnings attribute" do
      it "returns the relevant warnings" do
        expect(validator.warnings).to eq({ "Active Banner" => [
          "item 0 refers to a path /global-linked-to which is not currently live on gov.uk",
          "refers to an exclude_path /global-linked-to which is not currently live on gov.uk",
        ] })
      end
    end
  end
end
