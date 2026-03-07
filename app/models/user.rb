class User < ApplicationRecord
  has_many :receipts, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true

  def google_token_expired?
    google_token_expires_at.nil? || google_token_expires_at < Time.current
  end

  def refresh_google_token!
    return google_access_token unless google_token_expired?
    raise "No refresh token available" if google_refresh_token.blank?

    client_id = Rails.application.credentials.dig(:google, :client_id) || ENV["GOOGLE_CLIENT_ID"]
    client_secret = Rails.application.credentials.dig(:google, :client_secret) || ENV["GOOGLE_CLIENT_SECRET"]

    signet = Signet::OAuth2::Client.new(
      token_credential_uri: "https://oauth2.googleapis.com/token",
      client_id: client_id,
      client_secret: client_secret,
      refresh_token: google_refresh_token
    )
    signet.fetch_access_token!

    update!(
      google_access_token: signet.access_token,
      google_token_expires_at: Time.at(signet.expires_at)
    )

    signet.access_token
  end
end
