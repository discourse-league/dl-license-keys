module ::DlLicenseKeys
  class LicenseUserSerializer < ApplicationSerializer

    attributes :id,
      :enabled,
      :key,
      :created_at,
      :license,
      :sites,
      :site_count,
      :user

    def license
      licenses = PluginStore.get("dl_license_keys", "licenses")
      licenses = licenses.select{|license| license[:id] == object.license_id}
      licenses[0]
    end

    def sites
      license_user_sites = PluginStore.get("dl_license_keys", "license_user_sites") || []
      license_user_sites = license_user_sites.select{|site| object.id == site[:license_user_id]}
    end

    def site_count
      self.sites.count
    end

    def user
      BasicUserSerializer.new(User.find(object.user_id), root: false)
    end

  end
end