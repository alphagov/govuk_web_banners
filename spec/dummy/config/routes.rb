require "govuk_publishing_components"

Rails.application.routes.draw do
  mount GovukWebBanners::Engine => "/govuk_web_banners"
  mount GovukPublishingComponents::Engine, at: "/component-guide"
end
