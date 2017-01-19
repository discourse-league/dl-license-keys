require_dependency "licenses_constraint"
require_dependency "admin_constraint"

DlLicenseKeys::Engine.routes.draw do
  resource :licenses, path: '/products', constraints: AdminConstraint.new
  resource :license_users, path: '/license/users/:user_id', constraints: LicensesConstraint.new, only: [:show]
end