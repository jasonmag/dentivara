module Auditable
  extend ActiveSupport::Concern

  included do
    after_create_commit -> { audit!("create", previous_changes) }
    after_update_commit -> { audit!("update", previous_changes.except("updated_at")) }
    after_destroy_commit -> { audit!("destroy", attributes) }
  end

  private

  def audit!(action, changeset)
    return if changeset.blank?

    AuditLog.create!(
      clinic: respond_to?(:clinic) ? clinic : (Current.clinic || Clinic.default),
      user: Current.user,
      action: action,
      auditable_type: self.class.name,
      auditable_id: id,
      changeset: changeset
    )
  rescue StandardError
    nil
  end
end
