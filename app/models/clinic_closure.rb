class ClinicClosure < ApplicationRecord
  include TenantScoped

  validates :date, presence: true, uniqueness: { scope: :clinic_id }
end
