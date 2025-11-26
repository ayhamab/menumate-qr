class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :authorize_owner
  before_action :set_subscription, only: [:show, :update, :destroy, :cancel, :reactivate]

  # GET /restaurants/:restaurant_id/subscription
  def show
    @plans = Subscription.plans
  end

  # POST /restaurants/:restaurant_id/subscription/checkout
  def checkout
    plan_name = params[:plan_name] || 'basic'
    plan = Subscription.plans[plan_name]
    
    unless plan
      redirect_to restaurant_subscription_path(@restaurant), alert: "Invalid plan selected."
      return
    end

    Stripe.api_key = Rails.application.credentials.stripe[:secret_key] || ENV['STRIPE_SECRET_KEY']

    begin
      # Create or retrieve Stripe customer
      customer = if @restaurant.subscription&.stripe_customer_id.present?
        Stripe::Customer.retrieve(@restaurant.subscription.stripe_customer_id)
      else
        Stripe::Customer.create(
          email: current_user.email,
          metadata: {
            restaurant_id: @restaurant.id,
            user_id: current_user.id
          }
        )
      end

      # Create Stripe Checkout Session
      checkout_session = Stripe::Checkout::Session.create(
        customer: customer.id,
        payment_method_types: ['card'],
        mode: 'subscription',
        line_items: [{
          price: plan[:price_id] || create_stripe_price(plan_name, plan),
          quantity: 1
        }],
        success_url: success_restaurant_subscription_url(@restaurant),
        cancel_url: canceled_restaurant_subscription_url(@restaurant),
        metadata: {
          restaurant_id: @restaurant.id,
          plan_name: plan_name
        }
      )

      redirect_to checkout_session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      redirect_to restaurant_subscription_path(@restaurant), alert: "Error creating checkout session: #{e.message}"
    end
  end

  # GET /restaurants/:restaurant_id/subscription/success
  def success
    # This will be called after successful Stripe checkout
    # The webhook will actually create/update the subscription
    redirect_to restaurant_subscription_path(@restaurant), notice: "Subscription activated! Your subscription will be active shortly."
  end

  # GET /restaurants/:restaurant_id/subscription/canceled
  def canceled
    redirect_to restaurant_subscription_path(@restaurant), alert: "Subscription checkout was canceled."
  end

  # PATCH /restaurants/:restaurant_id/subscription
  def update
    plan_name = params[:plan_name]
    plan = Subscription.plans[plan_name]

    unless plan
      redirect_to restaurant_subscription_path(@restaurant), alert: "Invalid plan selected."
      return
    end

    Stripe.api_key = Rails.application.credentials.stripe[:secret_key] || ENV['STRIPE_SECRET_KEY']

    begin
      if @subscription.stripe_subscription_id.present?
        # Update existing subscription
        stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
        stripe_subscription.items = [{
          id: stripe_subscription.items.data[0].id,
          price: plan[:price_id] || create_stripe_price(plan_name, plan)
        }]
        stripe_subscription.proration_behavior = 'create_prorations'
        stripe_subscription.save

        @subscription.update(
          plan_name: plan_name,
          stripe_price_id: plan[:price_id]
        )

        redirect_to restaurant_subscription_path(@restaurant), notice: "Subscription updated successfully!"
      else
        redirect_to restaurant_subscription_path(@restaurant), alert: "No active subscription found."
      end
    rescue Stripe::StripeError => e
      redirect_to restaurant_subscription_path(@restaurant), alert: "Error updating subscription: #{e.message}"
    end
  end

  # POST /restaurants/:restaurant_id/subscription/cancel
  def cancel
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key] || ENV['STRIPE_SECRET_KEY']

    begin
      if @subscription.stripe_subscription_id.present?
        stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
        stripe_subscription.cancel_at_period_end = true
        stripe_subscription.save

        @subscription.update(cancel_at_period_end: true)

        redirect_to restaurant_subscription_path(@restaurant), notice: "Subscription will be canceled at the end of the billing period."
      else
        redirect_to restaurant_subscription_path(@restaurant), alert: "No active subscription found."
      end
    rescue Stripe::StripeError => e
      redirect_to restaurant_subscription_path(@restaurant), alert: "Error canceling subscription: #{e.message}"
    end
  end

  # POST /restaurants/:restaurant_id/subscription/reactivate
  def reactivate
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key] || ENV['STRIPE_SECRET_KEY']

    begin
      if @subscription.stripe_subscription_id.present?
        stripe_subscription = Stripe::Subscription.retrieve(@subscription.stripe_subscription_id)
        stripe_subscription.cancel_at_period_end = false
        stripe_subscription.save

        @subscription.update(cancel_at_period_end: false)

        redirect_to restaurant_subscription_path(@restaurant), notice: "Subscription reactivated successfully!"
      else
        redirect_to restaurant_subscription_path(@restaurant), alert: "No active subscription found."
      end
    rescue Stripe::StripeError => e
      redirect_to restaurant_subscription_path(@restaurant), alert: "Error reactivating subscription: #{e.message}"
    end
  end

  # DELETE /restaurants/:restaurant_id/subscription
  def destroy
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key] || ENV['STRIPE_SECRET_KEY']

    begin
      if @subscription.stripe_subscription_id.present?
        Stripe::Subscription.delete(@subscription.stripe_subscription_id)
      end

      @subscription.destroy
      redirect_to restaurant_subscription_path(@restaurant), notice: "Subscription canceled successfully."
    rescue Stripe::StripeError => e
      redirect_to restaurant_subscription_path(@restaurant), alert: "Error canceling subscription: #{e.message}"
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_subscription
    @subscription = @restaurant.subscription || @restaurant.build_subscription
  end

  def authorize_owner
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only manage subscriptions for your own restaurants."
      return
    end
  end

  def create_stripe_price(plan_name, plan)
    Stripe::Price.create(
      unit_amount: (plan[:price] * 100).to_i, # Convert to cents
      currency: 'usd',
      recurring: {
        interval: 'month'
      },
      product_data: {
        name: "#{plan[:name]} Plan - MenuMate QR"
      }
    ).id
  end
end
