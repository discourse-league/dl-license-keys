# name: dl-license-keys
# about: Adds the ability to create and validate license keys for members of groups.
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/discourseleague/dl-license-keys

enabled_site_setting :dl_license_keys_enabled

add_admin_route 'license_keys.title', 'licenses'

register_asset "stylesheets/dl-license-keys.scss"

Discourse::Application.routes.append do
  get '/admin/plugins/licenses' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/all' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/enabled' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/disabled' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/unused' => 'admin/plugins#index', constraints: StaffConstraint.new
end

load File.expand_path('../lib/dl_license_keys/engine.rb', __FILE__)

after_initialize do

  require_dependency 'groups_controller'
  class ::GroupsController

    after_filter :update_license_keys, only: [:add_members, :remove_member]

    def update_license_keys
      licenses = DlLicenseKeys::License.find_by_group_id(params[:id])
      if !licenses.blank?
        byebug
      end
    end
  end

end