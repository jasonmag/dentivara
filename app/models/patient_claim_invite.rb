class PatientClaimInvite < ApplicationRecord
  TOKEN_LENGTH = 32

  belongs_to :patient

  validates :token_digest, :expires_at, presence: true
  validates :token_digest, uniqueness: true

  scope :active, -> {
    where(claimed_at: nil).where("expires_at > ?", Time.current)
  }

  def self.issue!(patient, expires_at: 72.hours.from_now)
    raw_token = SecureRandom.urlsafe_base64(TOKEN_LENGTH)
    invite = create!(
      patient: patient,
      expires_at: expires_at,
      token_digest: digest(raw_token)
    )

    [ invite, raw_token ]
  end

  def self.authenticate(raw_token)
    return nil if raw_token.blank?

    active.find_by(token_digest: digest(raw_token))
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def claimed?
    claimed_at.present?
  end

  def mark_claimed!
    update!(claimed_at: Time.current)
  end
end
