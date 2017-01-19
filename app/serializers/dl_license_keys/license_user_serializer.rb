module ::DlLicenseKeys
  class LicenseUserSerializer < ApplicationSerializer

     attributes :enabled,
       :key,
       :license,
       :sites

    def license
      object.license
    end

    def sites
      object.license_user_sites
    end

  end
end