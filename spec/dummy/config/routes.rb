Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"
  mount GovukWebBanners::Engine => "/govuk_web_banners"

  get "/recruitment-with-banners", to: "banner_pages#recruitment"
  get "/recruitment-with-no-banners", to: "banner_pages#recruitment"

  get "/emergency", to: "banner_pages#emergency"
  get "/", to: "banner_pages#emergency_on_homepage"
end
