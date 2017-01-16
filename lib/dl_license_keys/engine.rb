module DlLicenseKeys
  class Engine < ::Rails::Engine
    isolate_namespace DlLicenseKeys

    config.after_initialize do
		Discourse::Application.routes.append do
			mount ::DlLicenseKeys::Engine, at: "/licenses"
		end
    end
  end
end