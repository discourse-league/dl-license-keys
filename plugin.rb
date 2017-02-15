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
  get '/admin/plugins/licenses/find' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/enabled' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/disabled' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/licenses/unused' => 'admin/plugins#index', constraints: StaffConstraint.new
  get "users/:username/licenses" => "users#show", constraints: {username: USERNAME_ROUTE_FORMAT}
  get '/licenses/license/users/all' => 'dl_license_keys/license_users#all_licenses', constraints: AdminConstraint.new
  put '/licenses/license/users/all' => 'dl_license_keys/license_users#update', constraints: AdminConstraint.new
end

load File.expand_path('../lib/dl_license_keys/engine.rb', __FILE__)

after_initialize do

  require_dependency 'group'
  class ::Group

    after_save :update_license_keys

    protected

    def update_license_keys
      Jobs.enqueue(:update_license_keys, {group_id: self.id})
    end

  end

  require_dependency "jobs/base"
  module ::Jobs

    class LogSiteLicenseValidation < Jobs::Base
      def execute(args)
        if (args[:license_user_id] && args[:site_url])
          license_user_sites = PluginStore.get("dl_license_keys", "license_user_sites")
          if license_user_sites.nil?
            license_user_sites = []
            site = []
          else
            site = license_user_sites.select{|site| site[:license_user_id] == args[:license_user_id] && site[:site_url] == args[:site_url]}
          end

          if site.nil?
            id = SecureRandom.random_number(1000000)

            until license_user_sites.select{|site| site[:id] == id}.empty?
              id = SecureRandom.random_number(1000000)
            end

            new_site = {
              id: id,
              license_user_id: args[:license_user_id],
              site_url: args[:site_url]
            }

            license_user_sites.push(new_site)
            
            PluginStore.set("dl_license_keys", "license_user_sites", license_user_sites)
          end
        end
      end
    end

    class UpdateLicenseKeys < Jobs::Base
      def execute(args)
        group = Group.find(args[:group_id])

        licenses = PluginStore.get("dl_license_keys", "licenses").select{|license| license[:group_id] = group.id} || []
        
        if !licenses.blank?

          users = group.users
          license_users = PluginStore.get("dl_license_keys", "license_users") || []

          id = SecureRandom.random_number(1000000)
          key = SecureRandom.hex(16)
          if !license_users.empty?
            until license_users.select{|license_user| license_user[:id] == id}.empty?
              id = SecureRandom.random_number(1000000)
            end
            until license_users.select{|license_user| license_user[:key] == key}.empty?
              key = SecureRandom.hex(16)
            end
          end

          time = Time.now

          licenses.each do |license|
            if license[:enabled]
              filtered_license_users = license_users.select{|license_user| license_user[:license_id] == license[:id]}
              license_users_ids = filtered_license_users.collect{|lu| lu[:user_id]}
              new_users = group.users.where.not(id: license_users_ids) || []
              disabled_users = filtered_license_users.select{|license_user| users.exclude?(license_user[:user_id])}
              existing_users = group.users.where(id: license_users_ids) || []

              new_users.each do |new_user|
                license_user = filtered_license_users.select{|license_user| license_user[:user_id] == new_user.id}

                if license_user.empty?
                  new_license_user = {
                    id: id,
                    enabled: true, 
                    user_id: new_user.id, 
                    license_id: license[:id], 
                    key: key,
                    created_at: time
                  }

                  license_users.push(new_license_user)

                  PluginStore.set("dl_license_keys", "license_users", license_users)

                  PostCreator.create(
                    Discourse.system_user,
                    target_usernames: new_user.username,
                    archetype: Archetype.private_message,
                    subtype: TopicSubtype.system_message,
                    title: I18n.t('license_keys.new_key_title', {productName: license[:product_name]}),
                    raw: I18n.t('license_keys.new_key_body', {username: new_user.username})
                  )
                else
                  license_user[0][:enabled] = true
                  PluginStore.set("dl_license_keys", "license_users", license_users)
                end
              end

              disabled_users.each do |disabled_user|
                license_user = filtered_license_users.select{|license_user| license_user[:user_id] == disabled_user[:user_id]}
                if !license_user.empty?
                  license_user[0][:enabled] = false
                  PluginStore.set("dl_license_keys", "license_users", license_users)
                end
              end

              existing_users.each do |existing_user|
                license_user = filtered_license_users.select{|license_user| license_user[:user_id] == existing_user.id}
                license_user[0][:enabled] = true
                PluginStore.set("dl_license_keys", "license_users", license_users)
              end

            end
          end

        end

      end
    end

  end

end