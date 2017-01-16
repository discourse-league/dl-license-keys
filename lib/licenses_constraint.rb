class LicensesConstraint
	def matches?(request)
		SiteSetting.dl_license_keys_enabled
	end
end