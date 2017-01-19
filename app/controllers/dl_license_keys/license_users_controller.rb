module DlLicenseKeys
  class LicenseUsersController < ApplicationController
    requires_plugin 'dl-license-keys'

    before_filter :fetch_license_user, only: [:show]

    def show
      render_json_dump(serialize_data(@license_user, LicenseUserSerializer))
    end

    private

    def fetch_license_user
      @license_user = LicenseUser.where(user_id: params[:user_id])
    end

    def license_params
      params.permit(license_user: [:enabled, :user_id, :license_id, :key])[:license_user]
    end

  end
end
