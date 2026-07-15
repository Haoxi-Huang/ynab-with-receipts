Rails.application.config.session_store :cookie_store,
  key: "_ynab_with_receipts_session",
  expire_after: 30.days,
  same_site: :lax,
  secure: Rails.env.production?
