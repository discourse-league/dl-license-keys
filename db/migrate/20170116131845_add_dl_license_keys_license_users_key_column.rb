class AddDlLicenseKeysLicenseUsersKeyColumn < ActiveRecord::Migration
  def change
    add_column :dl_license_keys_license_users, :key, :string, null: false
  end
end