class ClinicMembership < ApplicationRecord
  ROLES = User.roles.keys.freeze

  belongs_to :clinic
  belongs_to :user

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :clinic_id }
end
