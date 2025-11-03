# Review Collector - Deployment Guide

## Pre-Deployment Checklist

### 1. Environment Variables
Set the following environment variables in your hosting platform:

```bash
# Application
RAILS_ENV=production
RAILS_MASTER_KEY=<your-master-key>
APP_HOST=yourdomain.com
SECRET_KEY_BASE=<generate-with-rails-secret>

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Redis (for Solid Queue/Cache/Cable)
REDIS_URL=redis://localhost:6379/0

# Email (SendGrid/Postmark)
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=<your-smtp-username>
SMTP_PASSWORD=<your-smtp-password>

# Stripe
STRIPE_PUBLISHABLE_KEY=<your-publishable-key>
STRIPE_SECRET_KEY=<your-secret-key>
STRIPE_WEBHOOK_SECRET=<your-webhook-secret>

# Optional: Error Tracking
SENTRY_DSN=<your-sentry-dsn>
```

### 2. Database Setup
```bash
# Run migrations
bin/rails db:migrate RAILS_ENV=production

# Seed subscription plans
bin/rails db:seed RAILS_ENV=production
```

### 3. Asset Compilation
```bash
# Precompile assets
bin/rails assets:precompile RAILS_ENV=production
```

### 4. Stripe Configuration
1. Set up Stripe webhooks to point to: `https://yourdomain.com/pay/webhooks/stripe`
2. Enable the following events:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
3. Copy the webhook signing secret to `STRIPE_WEBHOOK_SECRET`

### 5. Email DNS Configuration

#### SPF Record
```
v=spf1 include:sendgrid.net ~all
```

#### DKIM Record
Get from SendGrid dashboard and add to DNS

#### DMARC Record
```
v=DMARC1; p=quarantine; rua=mailto:postmaster@yourdomain.com
```

### 6. SSL Certificate
- Ensure SSL certificate is active and valid
- Force HTTPS is already enabled in production.rb

### 7. Monitoring Setup
- Set up error tracking (Sentry recommended)
- Configure uptime monitoring
- Set up performance monitoring (optional)

## Deployment Options

### Option 1: Render.com

1. Connect GitHub repository
2. Create new Web Service
3. Set build command: `./bin/render-build.sh`
4. Set start command: `./bin/thrust bin/rails server`
5. Add environment variables
6. Add PostgreSQL database
7. Add Redis instance (optional, for caching)

### Option 2: Heroku

```bash
# Create app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:essential-0

# Add Redis (optional)
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set RAILS_ENV=production
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
heroku config:set APP_HOST=your-app-name.herokuapp.com

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
heroku run rails db:seed
```

### Option 3: Railway

1. Connect GitHub repository
2. Add PostgreSQL database
3. Add Redis (optional)
4. Set environment variables
5. Deploy automatically on push

### Option 4: Docker Deployment

```bash
# Build image
docker build -t review-collector .

# Run container
docker run -d \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e DATABASE_URL=postgresql://... \
  -e REDIS_URL=redis://... \
  --name review-collector \
  review-collector
```

## Post-Deployment Checklist

### Verify Functionality
- [ ] Application loads successfully
- [ ] User registration works
- [ ] Email confirmation sent
- [ ] User can sign in
- [ ] Dashboard displays correctly
- [ ] Can create a campaign
- [ ] Can add customers
- [ ] Can send review requests
- [ ] Stripe checkout works
- [ ] Webhooks receiving events
- [ ] Admin panel accessible (for admin users)
- [ ] API endpoints functional
- [ ] Rate limiting working
- [ ] Error pages display correctly

### Performance Check
- [ ] Page load times acceptable
- [ ] Database queries optimized
- [ ] Caching working properly
- [ ] SSL certificate valid
- [ ] CDN configured (if using)

### Security Check
- [ ] HTTPS enforced
- [ ] Security headers active (check with securityheaders.com)
- [ ] CSRF protection enabled
- [ ] Rate limiting active
- [ ] SQL injection protection verified
- [ ] Admin panel restricted

### Monitoring
- [ ] Error tracking active
- [ ] Uptime monitoring configured
- [ ] Email deliverability monitoring
- [ ] Database backups scheduled

## Backup Strategy

### Database Backups
```bash
# Manual backup
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# Automated backups (set up cron job or use hosting provider's backup feature)
```

### Restore from Backup
```bash
# Restore database
psql $DATABASE_URL < backup_20251014.sql
```

## Maintenance

### Update Dependencies
```bash
bundle update
bin/rails db:migrate
```

### Monitor Logs
```bash
# Heroku
heroku logs --tail

# Railway
railway logs

# Docker
docker logs -f review-collector
```

### Scale Workers
For background jobs (Solid Queue):
```bash
# Heroku
heroku ps:scale worker=2

# Or run separate dyno
heroku ps:scale solid_queue=1
```

## Troubleshooting

### Common Issues

1. **Database connection errors**
   - Verify DATABASE_URL is set correctly
   - Check database server is running
   - Ensure migrations are run

2. **Assets not loading**
   - Run `bin/rails assets:precompile`
   - Check RAILS_SERVE_STATIC_FILES is set

3. **Emails not sending**
   - Verify SMTP credentials
   - Check DNS records (SPF, DKIM, DMARC)
   - Test with `bin/rails console` and `ActionMailer::Base.deliveries`

4. **Stripe webhooks failing**
   - Verify webhook secret is correct
   - Check webhook URL is accessible
   - Review Stripe dashboard for errors

## Support

For issues or questions:
- Check application logs
- Review error tracking dashboard
- Consult Rails guides: https://guides.rubyonrails.org/
- Review Stripe documentation: https://stripe.com/docs

## Security Notes

- Never commit secrets to version control
- Rotate credentials regularly
- Keep dependencies updated
- Monitor for security vulnerabilities
- Enable 2FA for admin accounts
- Regular security audits recommended

---

**Last Updated:** October 2025
**Rails Version:** 8.0.3
**Ruby Version:** 3.4.5
