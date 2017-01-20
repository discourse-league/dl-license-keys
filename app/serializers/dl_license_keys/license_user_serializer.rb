module ::DlLicenseKeys
  class LicenseUserSerializer < ApplicationSerializer

    attributes :id,
      :enabled,
      :key,
      :license,
      :sites,
      :site_count

    has_one :user, serializer: BasicUserSerializer, embed: :objects

    def license
      object.license
    end

    def sites
      object.license_user_sites
    end

    def site_count
      object.license_user_sites.count
    end

  end
end