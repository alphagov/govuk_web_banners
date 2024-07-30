module GovukWebBanners
  class Engine < ::Rails::Engine
    isolate_namespace GovukWebBanners

    initializer "govuk_web_banners.engine" do
      ActiveSupport.on_load(:action_view) do
        include GovukWebBanners::ApplicationHelper
      end
    end
  end
end
