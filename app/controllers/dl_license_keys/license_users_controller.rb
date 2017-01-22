module DlLicenseKeys
  class LicenseUsersController < ApplicationController
    requires_plugin 'dl-license-keys'

    before_filter :fetch_license_user, only: [:show]

    skip_before_filter :check_xhr, only: [:validate]

    def show
      render_json_dump(serialize_data(@license_user, LicenseUserSerializer))
    end

    def all_licenses
      all_licenses = {}
      
      if params[:q]
        query = params[:q]
        users = User.where("username LIKE ?", "%#{query}%").pluck(:id)
        if users
          licenses = LicenseUser.where(user_id: users).sort
          all_licenses = serialize_data(licenses, LicenseUserSerializer)
        end
      end

      render_json_dump(all_licenses)
    end

    def update
      license_user = LicenseUser.find(params[:license_user][:id])
      if license_user
        license_user.enabled = params[:license_user][:enabled] if !params[:license_user][:enabled].nil?
        license_user.save
      end
      render_json_dump(license_user)
    end

    def validate
      license = LicenseUser.find_by(license_id: params[:id], key: params[:key])
      if license
        Jobs.enqueue(:log_site_license_validation, {license_user_id: license.id, site_url: request.env['HTTP_REFERER']})
        render_json_dump({:enabled => license.enabled, :license_id => license.license_id, :key => license.key})
      else
        render_json_error(license)
      end
    end

    private

    def fetch_license_user
      @license_user = LicenseUser.where(user_id: params[:user_id]).sort
    end

    def license_params
      params.permit(license_user: [:enabled, :user_id, :license_id, :key])[:license_user]
    end

  end
end
