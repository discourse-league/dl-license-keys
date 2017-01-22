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

  require_dependency 'groups_controller'
  class ::GroupsController

    after_filter :generate_license_keys, only: [:add_members]
    after_filter :disable_license_keys, only: [:remove_member]

    private

    def generate_license_keys
      @licenses = DlLicenseKeys::License.where(group_id: params[:id])
      if !@licenses.blank?

        users =
          if params[:usernames].present?
            User.where(username: params[:usernames].split(","))
          elsif params[:user_ids].present?
            User.find(params[:user_ids].split(","))
          elsif params[:user_emails].present?
            User.where(email: params[:user_emails].split(","))
          else
            raise Discourse::InvalidParameters.new(
              'user_ids or usernames or user_emails must be present'
            )
          end

        raise Discourse::NotFound if users.blank?

        users.each do |user|
          @licenses.each do |license|
            if license.enabled
              license_user = DlLicenseKeys::LicenseUser.find_by(user_id: user.id, license_id: license.id)
              if license_user.blank?

                key = SecureRandom.hex(16)
                collision = DlLicenseKeys::LicenseUser.find_by_key(key)

                until collision.nil?
                  key = SecureRandom.hex(16)
                  collision = DlLicenseKeys::LicenseUser.find_by_key(key)
                end

                new_license_user = DlLicenseKeys::LicenseUser.new(enabled: true, user_id: user.id, license_id: license.id, key: key)
                new_license_user.save
              else
                license_user.enabled = true
                license_user.save
              end
            end
          end
        end

      end

    end

    def disable_license_keys
      @licenses = DlLicenseKeys::License.where(group_id: params[:id])
      if !@licenses.blank?
        user =
          if params[:user_id].present?
            User.find_by(id: params[:user_id])
          elsif params[:username].present?
            User.find_by_username(params[:username])
          elsif params[:user_email].present?
            User.find_by_email(params[:user_email])
          else
            raise Discourse::InvalidParameters.new('user_id or username must be present')
          end

        raise Discourse::NotFound unless user

        @licenses.each do |license|
          if license.enabled
            license_user = DlLicenseKeys::LicenseUser.find_by(user_id: user.id, license_id: license.id)
            if !license_user.blank?
              license_user.enabled = false
              license_user.save
            end
          end
        end

      end
    end

  end

  require_dependency "jobs/base"
  module ::Jobs

    class LogSiteLicenseValidation < Jobs::Base
      def execute(args)
        if args[:license_user_id] && args[:site_url] && DlLicenseKeys::LicenseUser.find(args[:license_user_id])
          site = DlLicenseKeys::LicenseUserSite.find_by(license_user_id: args[:license_user_id], site_url: args[:site_url])
          if !site
            DlLicenseKeys::LicenseUserSite.create({:license_user_id => args[:license_user_id], :site_url => args[:site_url]})
          end
        end
      end
    end
  end

end