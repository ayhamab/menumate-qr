class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.stripe[:webhook_secret] || ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event.data.object)
    when 'customer.subscription.created'
      handle_subscription_created(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_succeeded'
      handle_invoice_payment_succeeded(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_payment_failed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    render json: { received: true }, status: 200
  end

  private

  def handle_checkout_session_completed(session)
    restaurant_id = session.metadata['restaurant_id']
    plan_name = session.metadata['plan_name'] || 'basic'
    
    restaurant = Restaurant.find_by(id: restaurant_id)
    return unless restaurant

    subscription = restaurant.subscription || restaurant.build_subscription
    subscription.update(
      stripe_customer_id: session.customer,
      plan_name: plan_name,
      status: 'active'
    )
  end

  def handle_subscription_created(subscription)
    restaurant = find_restaurant_by_customer(subscription.customer)
    return unless restaurant

    subscription_record = restaurant.subscription || restaurant.build_subscription
    subscription_record.update(
      stripe_subscription_id: subscription.id,
      stripe_customer_id: subscription.customer,
      status: subscription.status,
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end: Time.at(subscription.current_period_end),
      cancel_at_period_end: subscription.cancel_at_period_end
    )
  end

  def handle_subscription_updated(subscription)
    restaurant = find_restaurant_by_customer(subscription.customer)
    return unless restaurant

    subscription_record = restaurant.subscription
    return unless subscription_record

    subscription_record.update(
      status: subscription.status,
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end: Time.at(subscription.current_period_end),
      cancel_at_period_end: subscription.cancel_at_period_end,
      plan_name: extract_plan_name(subscription)
    )
  end

  def handle_subscription_deleted(subscription)
    restaurant = find_restaurant_by_customer(subscription.customer)
    return unless restaurant

    subscription_record = restaurant.subscription
    return unless subscription_record

    subscription_record.update(
      status: 'canceled',
      cancel_at_period_end: false
    )
  end

  def handle_invoice_payment_succeeded(invoice)
    restaurant = find_restaurant_by_customer(invoice.customer)
    return unless restaurant

    subscription_record = restaurant.subscription
    return unless subscription_record

    subscription_record.update(status: 'active')
  end

  def handle_invoice_payment_failed(invoice)
    restaurant = find_restaurant_by_customer(invoice.customer)
    return unless restaurant

    subscription_record = restaurant.subscription
    return unless subscription_record

    subscription_record.update(status: 'past_due')
  end

  def find_restaurant_by_customer(customer_id)
    Subscription.find_by(stripe_customer_id: customer_id)&.restaurant
  end

  def extract_plan_name(subscription)
    # Extract plan name from subscription items
    price_id = subscription.items.data[0]&.price&.id
    return 'basic' unless price_id

    plans = Subscription.plans
    plans.each do |name, plan|
      return name if plan[:price_id] == price_id
    end

    'basic'
  end
end
