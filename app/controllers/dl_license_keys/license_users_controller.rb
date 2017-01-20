module DlLicenseKeys
  class LicenseUsersController < ApplicationController
    requires_plugin 'dl-license-keys'

    before_filter :fetch_license_user, only: [:show]

    def show
      render_json_dump(serialize_data(@license_user, LicenseUserSerializer))
    end

    def all_licenses
      all_licenses = serialize_data(LicenseUser.all.sort, LicenseUserSerializer)
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

    private

    def fetch_license_user
      @license_user = LicenseUser.where(user_id: params[:user_id]).sort
    end

    def license_params
      params.permit(license_user: [:enabled, :user_id, :license_id, :key])[:license_user]
    end

  end
end
