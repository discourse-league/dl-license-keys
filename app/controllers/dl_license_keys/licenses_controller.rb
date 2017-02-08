module DlLicenseKeys
  class LicensesController < ApplicationController
    requires_plugin 'dl-license-keys'

    def create
      licenses = PluginStore.get("dl_license_keys", "licenses")
      id = SecureRandom.random_number(100000)

      if licenses.nil?
        licenses = []
      else
        until licenses.select{|license| license[:id] == id}.empty?
          id = SecureRandom.random_number(100000)
        end
      end

      new_license = {
        id: id,
        product_name: params[:product][:product_name],
        enabled: params[:product][:enabled],
        group_id: params[:product][:group_id]
      }

      licenses.push(new_license)
      PluginStore.set("dl_license_keys", "licenses", licenses)

      render json: new_license, root: false

    end

    def update
      licenses = PluginStore.get("dl_license_keys", "licenses")

      license = licenses.select{|license| license[:id] == params[:product][:id]}

      license[0][:product_name] = params[:product][:product_name] if !params[:product][:product_name].nil?
      license[0][:enabled] = params[:product][:enabled] if !params[:product][:enabled].nil?
      license[0][:group_id] = params[:product][:group_id] if !params[:product][:group_id].nil?

      PluginStore.set("dl_license_keys", "licenses", licenses)

      render json: license, root: false
    end

    def destroy
      licenses = PluginStore.get("dl_license_keys", "licenses")

      license = licenses.select{|license| license[:id] == params[:product][:id]}

      licenses.delete(license[0])

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
