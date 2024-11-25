Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"
  mount GovukWebBanners::Engine => "/govuk_web_banners"

  get "/page-with-banners", to: "banner_pages#show"
  get "/page-with-no-banners", to: "banner_pages#show"
end
