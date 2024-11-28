Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"
  mount GovukWebBanners::Engine => "/govuk_web_banners"

  get "/recruitment-with-banners", to: "banner_pages#recruitment"
  get "/recruitment-with-no-banners", to: "banner_pages#recruitment"
end
