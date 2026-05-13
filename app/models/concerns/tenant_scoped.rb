module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :clinic
    before_validation :assign_current_clinic
    default_scope { Current.clinic.present? ? where(clinic_id: Current.clinic.id) : all }

    scope :for_clinic, ->(clinic) { where(clinic_id: clinic.id) }
    scope :for_current_clinic, -> { Current.clinic.present? ? for_clinic(Current.clinic) : all }
  end

  private

  def assign_current_clinic
    self.clinic ||= Current.clinic || Clinic.default
  end
end
