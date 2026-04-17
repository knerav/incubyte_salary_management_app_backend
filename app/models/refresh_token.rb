class RefreshToken < ApplicationRecord
  EXPIRY = 7.days

  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def self.generate_for(user)
    raw = SecureRandom.urlsafe_base64(32)
    user.refresh_tokens.create!(
      token_digest: Digest::SHA256.hexdigest(raw),
      expires_at: EXPIRY.from_now
    )
    raw
  end

  def self.find_active_by_token(raw)
    digest = Digest::SHA256.hexdigest(raw)
    where("expires_at > ?", Time.current).find_by(token_digest: digest)
  end
end
