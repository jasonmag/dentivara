class AuditLog < ApplicationRecord
  require "digest"

  include TenantScoped

  belongs_to :user, optional: true

  validates :action, :auditable_type, :auditable_id, presence: true

  before_validation :assign_chain_hashes, on: :create

  private

  def assign_chain_hashes
    self.previous_hash ||= self.class.order(:id).last&.event_hash.to_s
    payload = [user_id, action, auditable_type, auditable_id, changeset.to_json, previous_hash].join("|")
    self.event_hash ||= Digest::SHA256.hexdigest(payload)
  end
end
