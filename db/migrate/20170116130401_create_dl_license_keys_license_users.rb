class CreateDlLicenseKeysLicenseUsers < ActiveRecord::Migration
  def change
    create_table :dl_license_keys_license_users do |t|
      t.boolean :enabled, default: false
      t.integer :user_id, null: false
      t.integer :license_id, null: false
      t.timestamps
    end
  end
end