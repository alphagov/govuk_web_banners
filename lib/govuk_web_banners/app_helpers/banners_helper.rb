module GovukWebBanners
  module BannersHelper
    def emergency_banner
      GovukWebBanners::EmergencyBanner.for_path(request.path)
    end

    def recruitment_banner
      return nil if emergency_banner

      GovukWebBanners::RecruitmentBanner.for_path(request.path)
    end
  end
end
