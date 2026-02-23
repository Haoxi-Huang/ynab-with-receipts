module AppConfig
  module_function

  def google_client_id
    credential(:google, :client_id) || ENV["GOOGLE_CLIENT_ID"]
  end

  def google_client_secret
    credential(:google, :client_secret) || ENV["GOOGLE_CLIENT_SECRET"]
  end

  def authorized_email
    credential(:authorized_email) || ENV["AUTHORIZED_EMAIL"]
  end

  def ynab_access_token
    credential(:ynab, :access_token) || ENV["YNAB_ACCESS_TOKEN"] || raise("Missing YNAB access token")
  end

  def ynab_budget_id
    credential(:ynab, :budget_id) || ENV["YNAB_BUDGET_ID"] || raise("Missing YNAB budget ID")
  end

  def app_host
    credential(:app_host) || ENV["APP_HOST"]
  end

  def credential(*keys)
    keys.reduce(Rails.application.credentials) do |cred, key|
      cred&.respond_to?(key) ? cred.send(key) : nil
    end
  end
end
