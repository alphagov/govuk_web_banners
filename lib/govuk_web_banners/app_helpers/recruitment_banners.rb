module GovukWebBanners
  module ApplicationHelper
    def recruitment_banner_present?
      RecruitmentBanner.for_path(request.path).present?
    end
  end
end
