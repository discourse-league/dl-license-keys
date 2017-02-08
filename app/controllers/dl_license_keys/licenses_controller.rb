module DlLicenseKeys
  class LicensesController < ApplicationController
    requires_plugin 'dl-license-keys'

    def create
      licenses = PluginStore.get("dl_license_keys", "licenses")
      id = SecureRandom.random_number(100000)

      if licenses.nil?
        licenses = []
      else
        until licenses[id].nil?
          id = SecureRandom.random_number(100000)
        end
      end

      new_license = {
        id: id,
        product_name: params[:product][:product_name],
        enabled: params[:product][:enabled],
        group_id: params[:product][:group_id]
      }

      licenses[id] = new_license
      PluginStore.set("dl_license_keys", "licenses", licenses)

      render json: new_license, root: false

    end

    def update
      licenses = PluginStore.get("dl_license_keys", "licenses")
      license = licenses[params[:product][:id]]

      license[:product_name] = params[:product][:product_name] if !params[:product][:product_name].nil?
      license[:enabled] = params[:product][:enabled] if !params[:product][:enabled].nil?
      license[:group_id] = params[:product][:group_id] if !params[:product][:group_id].nil?

      licenses[params[:product][:id]] = license

      PluginStore.set("dl_license_keys", "licenses", licenses)

      render json: license, root: false
    end

    def destroy
      licenses = PluginStore.get("dl_license_keys", "licenses")

      licenses[params[:product][:id]] = nil
      PluginStore.set("dl_license_keys", "licenses", licenses)

      render json: success_json
    end

    def show
      licenses = PluginStore.get("dl_license_keys", "licenses")
      licenses = [] if licenses.nil?
      render_json_dump(licenses.compact)
    end

    def all
      licenses = License.all
      render_json_dump(licenses)
    end

    private

    def license_params
      params.permit(product: [:enabled, :product_name, :group_id])[:product]
    end

  end
end
