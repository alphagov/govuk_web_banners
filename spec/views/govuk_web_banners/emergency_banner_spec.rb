describe "govuk_web_banners/_emergency_banner" do
  context "with no emergency banner present" do
    it "displays nothing" do
      render

      expect(rendered).to eq("")
    end
  end

  context "with an emergency banner present" do
    before { set_valid_emergency_banner }

    it "displays the banner" do
      render

      expect(rendered).to have_selector(".gem-c-emergency-banner")
    end

    it "displays with a heading and campaign colour" do
      render

      expect(rendered).to have_selector(".gem-c-emergency-banner--national-emergency")
      expect(rendered).to match("Some important information")
    end

    it "displays the more information link" do
      render

      expect(rendered).to match("See more")
      expect(rendered).to match(/www\.gov\.uk\/emergency/)
    end
  end

  context "with an emergency banner present without a link" do
    before { set_valid_emergency_banner(link: nil) }

    it "doesn't display the more information link" do
      render

      expect(rendered).not_to match("See more")
    end
  end
end
