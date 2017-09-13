module DlLicenseKeys
  class LicenseUsersController < ApplicationController
    requires_plugin 'dl-license-keys'

    skip_before_filter :check_xhr, only: [:validate]

    def show
      license_users = PluginStore.get("dl_license_keys", "license_users")

      if license_users.nil?
        user_licenses = []
      else
        user_licenses = license_users.select{|license_user| license_user[:user_id] == params[:user_id].to_i}
        user_licenses = user_licenses.flatten.map{|license| LicenseUser.new(license)} if !user_licenses.empty?
      end

      render_json_dump(serialize_data(user_licenses, LicenseUserSerializer))
    end

    def all_licenses
      all_licenses = {}

      if params[:q]
        query = params[:q]
        users = User.where("username LIKE ?", "%#{query}%").pluck(:id)
        if users
          license_users = PluginStore.get("dl_license_keys", "license_users")
          if license_users.nil?
            all_licenses = []
          else
            licenses = license_users.select{|license_user| users.include?(license_user[:user_id])}
            licenses = licenses.flatten.map{|license| LicenseUser.new(license)} if !licenses.empty?

            all_licenses = serialize_data(licenses, LicenseUserSerializer)
          end
        end
      end

      render_json_dump(all_licenses)
    end

    def update
      license_users = PluginStore.get("dl_license_keys", "license_users")
      if license_users.nil?
        license_user = nil
      else
        license_user = license_users.select{|license_user| license_user[:user_id] == params[:license_user][:user][:id] && license_user[:license_id] == params[:license_user][:license][:id]} if !license_users.blank?
      end

      if !license_user.nil?
        license_user[0][:enabled] = params[:license_user][:enabled] if !params[:license_user][:enabled].nil?
        PluginStore.set("dl_license_keys", "license_users", license_users)
      end

      render_json_dump(license_user[0])
    end

    def validate
      license_users = PluginStore.get("dl_license_keys", "license_users")
      license = license_users.select{|license_user| license_user[:license_id] == params[:id].to_i && license_user[:key] == params[:key]} if !license_users.blank?

      if license.empty?
        license = license_users.select{|license_user| license_user[:key] == params[:key]} if !license_users.blank?
      end
      
      if !license.empty?
        referer = request.headers['HTTP_REFERER']
        Jobs.enqueue(:log_site_license_validation, {license_user_id: license[0][:id], site_url: request.to_s})
        render_json_dump({:enabled => license[0][:enabled], :license_id => license[0][:license_id], :key => license[0][:key]})
      else
        render_json_error(license)
      end
    end

    private

    def license_params
      params.permit(license_user: [:enabled, :user_id, :license_id, :key])[:license_user]
    end

  end
end
