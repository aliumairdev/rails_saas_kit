# Rails SaaS Starter Kit

A **production-ready Rails 8 SaaS starter kit** with multi-tenancy, authentication, 2FA, payments, and all essential features to launch your SaaS product quickly. Focus on your business logic, not infrastructure.

## 🚀 Features

### 🔐 Authentication & Security
- **Devise** (custom branch) - Complete authentication with email confirmation, password recovery, and session tracking
- **Two-Factor Authentication (2FA)** - TOTP-based 2FA with QR codes, backup codes, and authenticator app support (ROTP + RQRCode)
- **Pundit** - Policy-based authorization for granular access control
- **Invisible Captcha** - Honeypot spam protection for forms
- **Secure Headers** - Industry-standard security headers
- **Rack Attack** - Rate limiting and throttling
- User profile management with avatar uploads
- Time zone support
- **Devise I18n** - Internationalization for authentication

### 🏢 Multi-Tenancy
- Account-based multi-tenancy architecture
- Personal and team accounts support
- Account switching functionality
- Account invitations system with email notifications
- Role-based access control (Owner, Admin, Member)
- Account settings and member management
- **Prefixed IDs** - Human-friendly IDs (e.g., `user_abc123`, `acct_xyz789`)

### 💳 Payments & Subscriptions
- **Pay gem 11.0** - Unified payment processing
- **Stripe 15.0** - Subscription billing and payment processing
- **Receipts** - Generate PDF receipts for payments
- Flexible plan management with customizable features
- Trial period support
- Subscription expiration monitoring
- Payment failed handling
- Customer portal for subscription management

### 📢 Notifications
- **Noticed 2.x** - Multi-channel notification system
- In-app notifications with unread counts
- Email notifications
- User notification preferences management
- Dismissible announcements system

### 🔑 API Support
- Token-based API authentication
- Secure API token generation with SHA256 hashing
- Token expiration and usage tracking
- RESTful API endpoints (v1)
- **Prefixed IDs** for API resources

### 📊 Admin Panel
- **Madmin 2.0** - Beautiful auto-generated admin interface
- **User Impersonation** (Pretender) - Impersonate users for support/debugging
- Full CRUD for all models (Users, Accounts, Plans, Subscriptions, etc.)
- Payment and subscription management via Madmin
- Notification and announcement management
- Activity tracking with PaperTrail versions
- Active Storage file management
- Role-based access (admin users only)
- Impersonation banner when impersonating users

### 🎨 Frontend & UI Components
- **Tailwind CSS 4.0** - Modern, utility-first styling
- **Hotwire** (Turbo + Stimulus) - SPA-like experience without complex JavaScript
- **Hotwire Combobox** - Autocomplete/combobox UI component
- **Local Time** - Timezone-aware time display in user's local timezone
- **Inline SVG** - SVG helper for inline icon rendering
- **Name of Person** - Smart name parsing (first_name, last_name, full_name)
- Responsive design
- Custom error pages (404, 422, 500)
- Landing page for marketing

### 📦 Modern Rails Features
- **Active Storage** - File uploads with image variants
- **Action Text** - Rich text editing for announcements
- **Solid Queue** - Database-backed job processing
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed ActionCable for WebSockets
- **ActionCable** - Real-time features with WebSocket support
- **Importmap** - JavaScript with ES modules (no Node.js required)

### 🛡️ Security & Monitoring
- **Rack Attack** - Rate limiting and throttling
- **Secure Headers** - Security headers configuration
- **Paper Trail** - Activity tracking and audit logs
- **Brakeman** - Security vulnerability scanning
- **Invisible Captcha** - Bot/spam protection
- **2FA** - Two-factor authentication with TOTP

### 📄 Content & Media
- **Ruby OEmbed** - Embed external content (YouTube, Vimeo, Twitter, etc.)
- Image processing with variants (thumbnails, medium)
- SVG support with inline rendering
- CSV export support
- PDF receipt generation

## 🛠 Tech Stack

### Core
- **Ruby on Rails 8.0.2+**
- **PostgreSQL** - Primary database
- **Puma** - Web server
- **Tailwind CSS 4.0** - Styling

### Authentication & Authorization
- **Devise** (custom branch with reset password proc)
- **Devise I18n** - Translations
- **Pundit** - Authorization
- **Pretender** - User impersonation
- **ROTP** - Two-factor authentication
- **RQRCode** - QR code generation

### Payments & Billing
- **Pay 11.0** - Payment processing
- **Stripe 15.0** - Payment gateway
- **Receipts** - PDF receipt generation

### Admin & Management
- **Madmin 2.0** - Admin interface
- **Paper Trail** - Audit logging
- **Noticed 2.x** - Notifications

### UI & Frontend
- **Hotwire** (Turbo + Stimulus)
- **Hotwire Combobox** - Autocomplete
- **Local Time** - Timezone display
- **Inline SVG** - SVG helpers
- **Name of Person** - Name parsing

### Utilities
- **Pagy** - Pagination
- **Prefixed IDs** - Friendly IDs
- **Ruby OEmbed** - Content embedding
- **Invisible Captcha** - Spam protection
- **Rack Attack** - Rate limiting
- **Secure Headers** - Security

### Development
- **Letter Opener** - Email preview
- **Brakeman** - Security scanning
- **Rubocop Rails Omakase** - Code styling

## 🎯 Getting Started

### Prerequisites

- Ruby 3.4+
- PostgreSQL 14+
- Node.js (for asset compilation)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd rails_saas_kit
```

2. Install dependencies:
```bash
bundle install
```

3. Setup database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Configure environment variables:
Create a `.env` file or set the following:
```bash
STRIPE_PUBLIC_KEY=your_stripe_public_key
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=your_webhook_secret
```

5. Start the server:
```bash
bin/dev
```

Visit `http://localhost:3000`

## ⚙️ Configuration

### Payment Plans

Configure subscription plans in the database or through seeds:
```ruby
Plan.create(
  name: "Pro",
  amount: 2900, # in cents
  interval: "month",
  interval_count: 1,
  currency: "usd",
  stripe_id: "price_xxx",
  details: {
    max_requests: 10000,
    max_campaigns: 100
  }
)
```

### Email Configuration

Update email settings in `config/environments/production.rb` for production email delivery.

### Two-Factor Authentication

Users can enable 2FA from their account settings:
1. Navigate to `/users/two_factor_authentication`
2. Scan QR code with authenticator app (Google Authenticator, Authy, etc.)
3. Save backup codes
4. Verify with 6-digit code

### Admin Access

The admin panel is powered by Madmin and available at `/madmin`. Create an admin user:
```ruby
user = User.find_by(email: 'admin@example.com')
user.update(admin: true)
```

Admin users can:
- Access `/madmin` to manage all resources
- Impersonate users for support/debugging
- View/manage subscriptions and payments
- Manage announcements
- View activity logs (PaperTrail versions)
- Manage file uploads

### User Impersonation

Admins can impersonate users:
```ruby
# In Madmin or custom admin interface
POST /admin/users/:user_id/impersonate

# Stop impersonating
DELETE /admin/impersonate
```

An impersonation banner appears when impersonating.

### Spam Protection

Forms are protected with Invisible Captcha:
```erb
<%= form_with model: @user do |f| %>
  <%= invisible_captcha %>
  <!-- form fields -->
<% end %>
```

### PDF Receipts

Generate receipts for payments:
```ruby
# In controller
pdf = generate_receipt_pdf(payment)
send_data pdf, filename: receipt_filename(payment), type: "application/pdf"
```

### Content Embedding

Embed external content:
```erb
<!-- Auto-detect and embed -->
<%= embed_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ") %>

<!-- YouTube -->
<%= embed_youtube("dQw4w9WgXcQ") %>

<!-- Vimeo -->
<%= embed_vimeo("123456789") %>
```

### Local Time

Display times in user's timezone:
```erb
<%= local_time(user.created_at) %>
<%= local_time(user.created_at, format: :long) %>
```

### Inline SVG

Render SVG icons inline:
```erb
<%= inline_svg "icon-name.svg", class: "w-6 h-6" %>
```

Place SVGs in `app/assets/images/`

### Prefixed IDs

Models have human-friendly IDs:
```ruby
user.id # => "user_abc123xyz"
account.id # => "acct_xyz789abc"
plan.id # => "plan_123abc456"
```

## 🧪 Development

### Running Tests
```bash
rails test
```

### Code Quality
```bash
# Security scanning
bundle exec brakeman

# Code linting
bundle exec rubocop
```

### Email Preview

Emails open automatically in browser (Letter Opener):
```ruby
# Send a test email
UserMailer.welcome_email(user).deliver_now
```

## 🚀 Deployment

Ready for deployment with:
- **Kamal** - Docker-based deployment
- **Thruster** - HTTP caching and acceleration
- Solid Queue for background jobs
- Solid Cable for WebSocket connections

### Docker Deployment

```bash
kamal setup
kamal deploy
```

## 📚 Documentation

### Key Models

- **User** - Has person name, prefixed IDs, 2FA methods
- **Account** - Multi-tenant accounts with prefixed IDs
- **Plan** - Subscription plans with feature flags
- **ApiToken** - Secure API authentication with prefixed IDs

### Key Controllers

- **Users::TwoFactorAuthenticationController** - 2FA management
- **Users::OtpController** - 2FA verification during login
- **Admin::ImpersonationsController** - User impersonation
- **Madmin Controllers** - Auto-generated admin CRUD

### Helpers

- **ReceiptsHelper** - PDF receipt generation
- **OembedHelper** - Content embedding
- **ApplicationHelper** - General helpers

## 🔒 Security Features

- ✅ Two-Factor Authentication (TOTP)
- ✅ Secure password hashing (bcrypt)
- ✅ API token SHA256 hashing
- ✅ CSRF protection
- ✅ SQL injection protection
- ✅ XSS protection
- ✅ Secure headers
- ✅ Rate limiting
- ✅ Spam protection
- ✅ Session security
- ✅ Audit logging

## 📊 Admin Features

- ✅ Auto-generated CRUD for all models
- ✅ User impersonation with banner
- ✅ Activity tracking (PaperTrail)
- ✅ File management (Active Storage)
- ✅ Subscription management
- ✅ Payment history
- ✅ Announcement system
- ✅ Role-based access

## 🎨 UI Components

- ✅ Tailwind CSS 4.0
- ✅ Responsive design
- ✅ Hotwire Combobox (autocomplete)
- ✅ Local Time (timezone display)
- ✅ Inline SVG icons
- ✅ Toast notifications
- ✅ Modal dialogs
- ✅ Form validation

## 🔧 Customization

### Adding New Features

1. Generate model: `rails g model Feature name:string`
2. Add to Madmin: `rails g madmin:resource Feature`
3. Add prefixed ID: `has_prefix_id :feat`
4. Add authorization: Create `FeaturePolicy`
5. Add views and controllers

### Customizing Madmin

Edit resources in `app/madmin/resources/`:
```ruby
class UserResource < Madmin::Resource
  # Customize fields, filters, etc.
end
```

## 📖 API Documentation

API endpoints available at `/api/v1/`:
- GET/POST `/campaigns`
- GET/POST `/customers`
- GET/POST `/review_requests`

Authentication: Bearer token in Authorization header
```bash
curl -H "Authorization: Bearer your_api_token" https://example.com/api/v1/campaigns
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

### What this means:
- ✅ You can use this code for personal and commercial projects
- ✅ You can modify and distribute the code
- ✅ You must disclose your source code when you distribute or provide the software as a service
- ✅ You must include the original license and copyright notice
- ✅ Changes must be documented and also licensed under AGPL-3.0

### Key AGPL-3.0 Requirements:
The AGPL-3.0 license requires that if you run a modified version of this software as a web service (SaaS), you must make your modified source code available to users of that service.

For full license details, see the LICENSE file or visit https://www.gnu.org/licenses/agpl-3.0.html

### Attribution
See [ATTRIBUTION.md](ATTRIBUTION.md) for credits and acknowledgments of the open-source projects this kit is built upon.

## 🆘 Support

For issues and questions, please open a GitHub issue.

## 🎉 What's Included

This starter kit includes everything you need for a production SaaS:

✅ **Authentication** - Devise with 2FA, email confirmation, password reset
✅ **Authorization** - Pundit policies
✅ **Multi-Tenancy** - Account-based with invitations
✅ **Payments** - Stripe subscriptions with trials
✅ **Admin Panel** - Madmin with impersonation
✅ **Notifications** - In-app and email
✅ **API** - Token-based REST API
✅ **Security** - 2FA, rate limiting, spam protection
✅ **UI Components** - Tailwind, Hotwire, autocomplete
✅ **File Uploads** - Active Storage with variants
✅ **Audit Logs** - Paper Trail
✅ **Background Jobs** - Solid Queue
✅ **Real-time** - ActionCable with Solid Cable
✅ **PDF Generation** - Receipts
✅ **Content Embedding** - YouTube, Vimeo, etc.
✅ **Internationalization** - Devise I18n
✅ **Development Tools** - Letter Opener, Brakeman

**Just add your business logic and ship! 🚀**
