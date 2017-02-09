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
      license_users = PluginStore.get("dl_license_keys", "license_users")
      if license_users.nil?
        return []
      else
        license_users = license_users.select{|license_user| license_user[:user_id] == object.user_id}
        license_user_sites = PluginStore.get("dl_license_keys", "license_user_sites")
        if license_users.nil? || license_user_sites.nil?
          return []
        else
          license_user_sites = license_user_sites.select{|site| license_users.include?(site[:license_user_id])}
          return license_user_sites
        end
      end
    end

    def site_count
      self.sites.count
    end

    def user
      BasicUserSerializer.new(User.find(object.user_id), root: false)
    end

  end
end