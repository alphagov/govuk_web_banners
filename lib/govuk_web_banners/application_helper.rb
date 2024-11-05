module GovukWebBanners
  module ApplicationHelper
    def recruitment_banner
      RecruitmentBanner.for_path(request.path)
    end
  end
end
