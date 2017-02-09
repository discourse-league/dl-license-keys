module ::DlLicenseKeys
	class LicenseUser
    alias :read_attribute_for_serialization :send

    attr_accessor :id, :enabled, :user_id, :license_id, :key, :created_at

    def initialize(opts={})
      @id = opts[:id]
      @enabled = opts[:enabled]
      @user_id = opts[:user_id]
      @license_id = opts[:license_id]
      @key = opts[:key]
      @created_at = opts[:created_at]
    end

	end
end