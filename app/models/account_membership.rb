class AccountMembership < ApplicationRecord
  ROLES = %w[owner admin member billing].freeze

  belongs_to :account
  belongs_to :user

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :account_id }
end
