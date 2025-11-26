# Stripe Subscription Setup Guide

This guide will help you set up Stripe subscriptions for MenuMate QR.

## Prerequisites

1. A Stripe account (sign up at https://stripe.com)
2. Stripe API keys (available in your Stripe Dashboard)

## Configuration Steps

### 1. Get Your Stripe API Keys

1. Log in to your Stripe Dashboard
2. Go to Developers > API keys
3. Copy your **Publishable key** and **Secret key**
4. For webhooks, you'll need to set up an endpoint (see step 4)

### 2. Set Environment Variables

Add these to your `.env` file or Rails credentials:

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

Or use Rails credentials:

```bash
rails credentials:edit
```

Add:
```yaml
stripe:
  publishable_key: pk_test_...
  secret_key: sk_test_...
  webhook_secret: whsec_...
```

### 3. Create Stripe Products and Prices

In your Stripe Dashboard:

1. Go to Products
2. Create three products:
   - **Basic Plan** - $9.99/month
   - **Pro Plan** - $29.99/month
   - **Enterprise Plan** - $99.99/month

3. For each product, create a recurring monthly price
4. Copy the Price IDs (they start with `price_...`)

### 4. Set Price IDs in Environment

Add the Price IDs to your environment:

```bash
STRIPE_BASIC_PRICE_ID=price_...
STRIPE_PRO_PRICE_ID=price_...
STRIPE_ENTERPRISE_PRICE_ID=price_...
```

### 5. Set Up Webhook Endpoint

1. In Stripe Dashboard, go to Developers > Webhooks
2. Click "Add endpoint"
3. Set the endpoint URL to: `https://yourdomain.com/webhooks/stripe`
4. Select these events to listen to:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copy the **Signing secret** (starts with `whsec_...`)
6. Add it to your environment as `STRIPE_WEBHOOK_SECRET`

### 6. Test Mode vs Live Mode

- **Test Mode**: Use test API keys (start with `pk_test_` and `sk_test_`)
- **Live Mode**: Use live API keys (start with `pk_live_` and `sk_live_`)

For development, use test mode. For production, use live mode.

## Testing

### Test Cards

Use these test card numbers in Stripe Checkout:

- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- **Requires Authentication**: `4000 0025 0000 3155`

Use any future expiry date, any 3-digit CVC, and any ZIP code.

### Testing Webhooks Locally

Use Stripe CLI to forward webhooks to your local server:

```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

This will give you a webhook signing secret to use in development.

## Subscription Plans

### Basic Plan - $9.99/month
- Up to 50 menu items
- Basic analytics
- QR code generation
- Email support
- 1 restaurant location
- 5 promotions
- 2 languages

### Pro Plan - $29.99/month
- Unlimited menu items
- Advanced analytics
- QR code generation
- Priority support
- 5 restaurant locations
- Unlimited promotions
- Multi-language support
- Custom branding

### Enterprise Plan - $99.99/month
- Everything in Pro
- Unlimited locations
- API access
- Dedicated account manager
- Custom integrations
- White-label solution
- Advanced security features
- SLA guarantee

## Troubleshooting

### Webhook Not Receiving Events

1. Check that your webhook endpoint URL is correct
2. Verify the webhook secret matches
3. Check Stripe Dashboard > Webhooks for delivery logs
4. Ensure your server is accessible from the internet (use ngrok for local testing)

### Subscription Not Updating

1. Check webhook logs in Stripe Dashboard
2. Verify webhook events are being received
3. Check application logs for errors
4. Ensure database migrations have been run

### Payment Fails

1. Check that test cards are being used in test mode
2. Verify customer has sufficient funds
3. Check Stripe Dashboard > Payments for error details
4. Review subscription status in the application

## Support

For Stripe-specific issues, consult:
- Stripe Documentation: https://stripe.com/docs
- Stripe Support: https://support.stripe.com

