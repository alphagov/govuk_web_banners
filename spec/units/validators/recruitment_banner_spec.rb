require "govuk_web_banners/validators/recruitment_banner"

RSpec.describe GovukWebBanners::Validators::RecruitmentBanner do
  let(:banner_class) { GovukWebBanners::RecruitmentBanner }
  let(:subject) { described_class.new(GovukWebBanners::RecruitmentBanner.all_banners) }

  before do
    original_path = Rails.root.join(__dir__, "../", banner_class::BANNER_CONFIG_FILE)
    allow(YAML).to receive(:load_file).with(original_path).and_return(replacement_file)

    stub_request(:get, %r{\Ahttps://www\.gov\.uk/api/content/.*})
  end

  context "with valid banners" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/active_recruitment_banners.yml"))
    end

    describe ".valid?" do
      it "returns true" do
        expect(subject.valid?).to be true
      end
    end

    describe "errors attribute" do
      it "returns an empty array" do
        expect(subject.errors).to be_empty
      end
    end
  end

  context "with invalid banners" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/invalid_recruitment_banners.yml"))
    end

    describe ".valid?" do
      it "returns false" do
        expect(subject.valid?).to be false
      end
    end

    describe "errors attribute" do
      it "returns the relevant errors" do
        expect(subject.errors["Empty Survey URL"]).to eq(["is missing a survey_url"])
        expect(subject.errors["Suggestion Link Text Broken"]).to eq(["is missing a suggestion_link_text"])
        expect(subject.errors["Page Paths Empty"]).to eq(["is missing any page_paths"])
        expect(subject.errors["Suggestion Text Empty"]).to eq(["is missing a suggestion_text"])
        expect(subject.errors["Page Paths include invalid path"]).to eq(["page_path views/old should start with a /"])
      end
    end
  end

  context "with a banner that has expired" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/expired_recruitment_banners.yml"))
    end

    before { travel_to Time.local(2024, 1, 2) }
    after { travel_back }

    describe ".valid?" do
      it "returns true" do
        expect(subject.valid?).to be true
      end
    end

    describe ".warnings?" do
      it "returns true" do
        expect(subject.warnings?).to be true
      end
    end

    describe "warnings attribute" do
      it "returns the relevant warnings" do
        expect(subject.warnings).to eq({ "Banner 1" => ["is expired"] })
      end
    end
  end

  context "with banners on the same path" do
    context "that aren't active at the same time" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/path_clash_different_times_recruitment_banners.yml"))
      end

      describe ".valid?" do
        it "returns true" do
          expect(subject.valid?).to be true
        end
      end

      describe "errors attribute" do
        it "returns an empty array" do
          expect(subject.errors).to be_empty
        end
      end
    end

    context "that are active at the same time" do
      let(:replacement_file) do
        YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/path_clash_same_time_recruitment_banners.yml"))
      end

      describe ".valid?" do
        it "returns false" do
          expect(subject.valid?).to be false
        end
      end

      describe "errors attribute" do
        it "returns the relevant errors" do
          expect(subject.errors["Banner feb-apr"]).to eq(["is active at the same time as Banner jan-mar and points to the same paths"])
          expect(subject.errors["Banner jan-mar"]).to eq(["is active at the same time as Banner feb-apr and points to the same paths"])
        end
      end
    end
  end

  context "with a path that doesn't exist on the live site" do
    let(:replacement_file) do
      YAML.load_file(Rails.root.join(__dir__, "../../../spec/fixtures/active_recruitment_banners.yml"))
    end

    before do
      stub_request(:get, %r{\Ahttps://www\.gov\.uk/api/content/email-signup}).to_return(status: 404)
    end

    describe ".valid?" do
      it "returns true" do
        expect(subject.valid?).to be true
      end
    end

    describe ".warnings?" do
      it "returns true" do
        expect(subject.warnings?).to be true
      end
    end

    describe "warnings attribute" do
      it "returns the relevant warnings" do
        expect(subject.warnings).to eq({ "Banner 2" => ["refers to a path /email-signup which is not currently live on gov.uk"] })
      end
    end
  end
end
