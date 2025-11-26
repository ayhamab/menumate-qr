Rails.application.config.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key),
  webhook_secret: ENV['STRIPE_WEBHOOK_SECRET'] || Rails.application.credentials.dig(:stripe, :webhook_secret)
}

Stripe.api_key = Rails.application.config.stripe[:secret_key] if Rails.application.config.stripe[:secret_key].present?

