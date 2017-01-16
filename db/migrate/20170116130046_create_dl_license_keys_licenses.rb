class CreateDlLicenseKeysLicenses < ActiveRecord::Migration
  def change
    create_table :dl_license_keys_licenses do |t|
      t.boolean :enabled, default: false
      t.string :product_name, null: false
      t.integer :group_id, null: false
      t.timestamps
    end
  end
end