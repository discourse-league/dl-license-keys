module ::DlLicenseKeys
	class LicenseUserSite < ActiveRecord::Base
		belongs_to :license_user
	end
end

# == Schema Information
#
# Table name: dl_license_keys_license_user_sites
#
#  id                :integer          not null, primary key
#  license_user_id   :integer          not null
#  site_url          :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null