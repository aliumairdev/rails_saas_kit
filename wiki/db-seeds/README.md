# Database Seeds

This directory contains the seed data for the Review Collector application.

## Running Seeds

To seed your database, run:

```bash
bin/rails db:seed
```

Or to reset and seed:

```bash
bin/rails db:reset
```

## What Gets Seeded

### Subscription Plans

The seed file creates 4 subscription plans:

1. **Free** - $0/month
   - 100 review requests
   - 5 campaigns
   - Email support

2. **Starter** - $9.90/month
   - 1,000 review requests
   - 20 campaigns
   - Email + SMS notifications
   - 14-day free trial

3. **Pro** - $29/month (Most Popular)
   - 5,000 review requests
   - 100 campaigns
   - Email + SMS notifications
   - Priority support
   - API access
   - 14-day free trial

4. **Enterprise** - $99/month
   - 99,999 review requests (essentially unlimited)
   - 9,999 campaigns (essentially unlimited)
   - Email + SMS notifications
   - Priority support
   - API access
   - Custom integrations
   - Dedicated account manager
   - 14-day free trial

### Demo Admin User (Development Only)

In development environment, a demo admin user is created:

- **Email**: admin@example.com
- **Password**: password123
- **Account**: Personal account is automatically created

## Stripe Integration

To connect plans with Stripe, set the following environment variables:

```bash
STRIPE_STARTER_PRICE_ID=price_xxxxx
STRIPE_PRO_PRICE_ID=price_xxxxx
STRIPE_ENTERPRISE_PRICE_ID=price_xxxxx
```

These should match the Price IDs from your Stripe dashboard.

## Idempotency

The seed file uses `find_or_create_by!` to ensure it can be run multiple times without creating duplicates. Plans are identified by their name.

## Customizing Plans

To modify plan details, edit `db/seeds.rb` and update the plan attributes. The `details` hash is stored as JSONB and can contain any custom attributes you need for your business logic.

Common detail fields:
- `max_requests` - Maximum review requests per month
- `max_campaigns` - Maximum active campaigns
- `email_support` - Email support availability
- `sms_notifications` - SMS notification feature
- `priority_support` - Priority support tier
- `api_access` - API access enabled
- `custom_integrations` - Custom integration support
- `dedicated_account_manager` - Dedicated account manager

## Production Deployment

For production deployments, you may want to:

1. Remove or comment out the demo admin user creation
2. Set appropriate Stripe Price IDs in environment variables
3. Adjust plan pricing and limits based on your business model
