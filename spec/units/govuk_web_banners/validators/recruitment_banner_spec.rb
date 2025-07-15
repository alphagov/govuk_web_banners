require "govuk_web_banners/validators/recruitment_banner"

RSpec.describe GovukWebBanners::Validators::RecruitmentBanner do
  subject(:validator) { described_class.new(GovukWebBanners::RecruitmentBanner.all_banners) }

  let(:fixtures_dir) { Rails.root.join(__dir__, "../../../../spec/fixtures/") }

  before do
    original_path = Rails.root.join(__dir__, "../../", GovukWebBanners::RecruitmentBanner::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)

    stub_request(:get, %r{\Ahttps://www\.gov\.uk/api/content/.*})
  end

  context "with valid banners" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "active_recruitment_banners.yml"))
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
      YAML.load_file(Rails.root.join(fixtures_dir, "invalid_recruitment_banners.yml"))
    end

    describe ".valid?" do
      it "returns false" do
        expect(validator.valid?).to be false
      end
    end

    describe "errors attribute" do
      it "returns the relevant errors" do
        expect(validator.errors["Empty Survey URL"]).to eq(["is missing a survey_url"])
        expect(validator.errors["Suggestion Link Text Broken"]).to eq(["is missing a suggestion_link_text"])
        expect(validator.errors["Page Paths Empty"]).to eq(["is missing any page_paths"])
        expect(validator.errors["Suggestion Text Empty"]).to eq(["is missing a suggestion_text"])
        expect(validator.errors["Page Paths include invalid path"]).to eq(["page_path views/old should start with a /"])
        expect(validator.errors["Dates inverted"]).to eq(["start_date is after end_date"])
      end
    end
  end

  context "with a banner that has expired" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "expired_recruitment_banners.yml"))
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
        expect(validator.warnings).to eq({ "Banner 1" => ["is expired"] })
      end
    end
  end

  context "with banners on the same path" do
    context "when they aren't active at the same time" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(fixtures_dir, "path_clash_different_times_recruitment_banners.yml"))
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

    context "when they are active at the same time" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(fixtures_dir, "path_clash_same_time_recruitment_banners.yml"))
      end

      describe ".valid?" do
        it "returns false" do
          expect(validator.valid?).to be false
        end
      end

      describe "errors attribute" do
        it "returns the relevant errors" do
          expect(validator.errors["Banner feb-apr"]).to eq(["is active at the same time as Banner jan-mar and points to the same paths"])
          expect(validator.errors["Banner jan-mar"]).to eq(["is active at the same time as Banner feb-apr and points to the same paths"])
        end
      end
    end
  end

  context "with a path that doesn't exist on the live site" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "active_recruitment_banners.yml"))
    end

    before do
      stub_request(:get, %r{\Ahttps://www\.gov\.uk/api/content/email-signup}).to_return(status: 404)
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
        expect(validator.warnings).to eq({ "Banner 2" => ["refers to a path /email-signup which is not currently live on gov.uk"] })
      end
    end
  end

  context "with banners with invalid images" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(fixtures_dir, "images_recruitment_banners.yml"))
    end

    describe ".valid?" do
      it "returns false" do
        expect(validator.valid?).to be false
      end
    end

    describe "errors attribute" do
      it "returns the relevant errors" do
        expect(validator.errors["Banner 2"]).to eq(["includes an invalid image value (dwp)"])
      end
    end
  end
end
