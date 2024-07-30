module GovukWebBanners
  class Engine < ::Rails::Engine
    isolate_namespace GovukWebBanners

    initializer "govuk_web_banners.engine" do
      ActionView::Base.include(GovukWebBanners::ApplicationHelper)
    end
  end
end
