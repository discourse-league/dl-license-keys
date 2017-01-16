class CreateDlLicenseKeysLicenseUserSites < ActiveRecord::Migration
  def change
    create_table :dl_license_keys_license_user_sites do |t|
      t.integer :license_user_id, null: false
      t.string :site_url, null: false
      t.timestamps
    end
  end
end