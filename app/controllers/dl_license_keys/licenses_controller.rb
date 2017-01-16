module DlLicenseKeys
  class LicensesController < ApplicationController
    requires_plugin 'dl-license-keys'

    before_filter :fetch_license, only: [:update, :destroy]

    def create
      license = License.create(license_params)
      if license.valid?
        render json: license, root: false
      else
        render_json_error(license)
      end
    end

    def update
      @license.product_name = params[:product][:product_name] if !params[:product][:product_name].nil?
      @license.enabled = params[:product][:enabled] if !params[:product][:enabled].nil?
      @license.group_id = params[:product][:group_id] if !params[:product][:group_id].nil?
      @license.save

      if @license.valid?
        render json: @license, root: false
      else
        render_json_error(@license)
      end
    end

    def destroy
      @license.destroy
      render json: success_json
    end

    def show
      licenses = License.all
      render_json_dump(licenses)
    end

    def all
      licenses = License.all
      render_json_dump(licenses)
    end

    private

    def fetch_license
      @license = License.find(params[:product][:id])
    end

    def license_params
      params.permit(product: [:enabled, :product_name, :group_id])[:product]
    end

  end
end
