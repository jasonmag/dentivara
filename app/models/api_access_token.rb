class ApiAccessToken < ApplicationRecord
  TOKEN_LENGTH = 32

  belongs_to :user

  validates :name, :token_digest, presence: true
  validates :token_digest, uniqueness: true

  scope :active, -> {
    where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current)
  }

  def self.generate!(user:, name:, scopes: [], expires_at: nil)
    raw_token = SecureRandom.urlsafe_base64(TOKEN_LENGTH)
    access_token = create!(
      user: user,
      name: name,
      scopes: Array(scopes).map(&:to_s),
      expires_at: expires_at,
      token_digest: digest(raw_token)
    )

    [ access_token, raw_token ]
  end

  def self.authenticate(raw_token)
    return nil if raw_token.blank?

    active.find_by(token_digest: digest(raw_token))
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def touch_usage!(request)
    update_columns(
      last_used_at: Time.current,
      last_used_ip: request.remote_ip,
      last_used_user_agent: request.user_agent.to_s.truncate(255),
      updated_at: Time.current
    )
  end
end
