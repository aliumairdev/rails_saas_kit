# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial public release preparation
- Comprehensive documentation (CONTRIBUTING.md, TESTING_ROADMAP.md, ATTRIBUTION.md)
- GitHub issue templates (bug report, feature request, question)
- Pull request template with detailed checklist
- CI/CD workflows (GitHub Actions for testing, linting, security scanning)
- API authentication tests (password auth, bearer token validation)
- OAuth integration tests (GitHub, Google, Facebook, Twitter)
- ConnectedAccount model tests
- API endpoint tests for /api/v1/auth and /api/v1/me
- AGPL-3.0 license documentation and attribution
- Professional README badges (CI status, license, versions)
- Deployment workflow template

### Changed
- Updated license from proprietary to AGPL-3.0
- Removed commercial template references from documentation
- Updated contributing section to reference new CONTRIBUTING.md
- Enhanced README with comprehensive AGPL-3.0 license information

### Security
- Added automated security scanning with Brakeman
- Added dependency vulnerability checking with bundler-audit
- Documented security best practices in CONTRIBUTING.md

## [1.0.0] - 2025-11-07

### Added

#### Core Features
- **Authentication & Security**
  - Devise authentication with custom branch (sign-in after reset password)
  - Two-Factor Authentication (2FA) with TOTP, QR codes, and backup codes
  - OAuth/Social login (GitHub, Google, Facebook, Twitter)
  - Pundit authorization with role-based access control
  - API token authentication with SHA256 hashing
  - Invisible Captcha spam protection
  - Secure headers and CSP configuration
  - Rack Attack rate limiting (100 req/min per IP, 1000/hr per token)

- **Multi-Tenancy**
  - Account-based architecture (personal and team accounts)
  - Account switching functionality
  - Team invitations with email notifications
  - Role-based access control (Owner, Admin, Member)
  - Account settings and member management
  - Prefixed IDs for human-friendly identifiers

- **Payments & Subscriptions**
  - Stripe integration via Pay gem 11.0
  - Subscription management with plan tiers
  - Trial period support with expiration monitoring
  - Payment method management
  - Billing portal for self-service
  - PDF receipt generation
  - Webhook handling for payment events

- **Notifications**
  - Noticed 2.x multi-channel notifications
  - In-app notifications with unread counts
  - Email notifications with professional templates
  - Real-time notifications via ActionCable
  - User notification preferences
  - Announcement system with dismissals

- **API Support**
  - RESTful JSON API v1
  - Bearer token authentication
  - Password authentication endpoint
  - Current user endpoint (/api/v1/me)
  - Rate limiting integration
  - Prefixed IDs for API resources

- **Admin Panel**
  - Madmin 2.0 auto-generated admin interface
  - User impersonation with Pretender gem
  - Full CRUD for all models
  - Activity tracking with PaperTrail
  - Active Storage file management
  - Role-based admin access

- **Frontend & UI**
  - TailwindCSS 4.0 with modern utility classes
  - Hotwire (Turbo + Stimulus) for SPA-like experience
  - Hotwire Combobox for autocomplete
  - Local Time for timezone-aware display
  - Inline SVG support
  - Responsive design
  - Custom error pages (404, 422, 500)

- **Modern Rails Features**
  - Active Storage for file uploads
  - Action Text for rich text editing
  - Solid Queue for background jobs
  - Solid Cache for database-backed caching
  - Solid Cable for WebSocket connections
  - ActionCable for real-time features
  - Importmap for ES modules (no Node.js required)

- **Developer Tools**
  - Letter Opener for email preview
  - Brakeman security scanning
  - RuboCop with Rails Omakase style
  - Comprehensive test suite (Minitest)
  - Capybara for system tests
  - WebMock for HTTP stubbing

#### Models
- User (with Devise, 2FA, OAuth, notification preferences)
- Account (multi-tenant accounts with subscriptions)
- AccountUser (team membership with roles)
- AccountInvitation (token-based invitations)
- Plan (subscription plans with feature flags)
- ApiToken (secure API authentication)
- Announcement (news and updates with rich text)
- AnnouncementDismissal (user dismissal tracking)
- ConnectedAccount (OAuth provider management)

#### Test Coverage
- 160+ model tests (80% coverage)
- Integration tests for authentication and 2FA
- System tests for user registration
- API client tests with WebMock
- Comprehensive fixtures for all models

#### Documentation
- Comprehensive README with feature list and setup guide
- API documentation with examples
- OAuth setup guide for all providers
- JavaScript/Stimulus documentation
- TailwindCSS configuration guide
- Deployment guide (Docker, Kamal, Thruster)
- Implementation status tracker

### Dependencies

#### Core
- Ruby 3.4+
- Rails 8.0.2+
- PostgreSQL 14+
- Tailwind CSS 4.0

#### Major Gems
- Devise (authentication)
- Pundit (authorization)
- Pay 11.0 (payments)
- Stripe 15.0 (payment gateway)
- Noticed 2.2 (notifications)
- Madmin 2.0 (admin panel)
- Hotwire (Turbo + Stimulus)
- Paper Trail (audit logging)
- ROTP + RQRCode (2FA)
- OmniAuth + 4 providers (OAuth)

See [ATTRIBUTION.md](ATTRIBUTION.md) for complete dependency list.

---

## Release Notes

### Version 1.0.0 - Initial Public Release

This is the first public release of Rails SaaS Kit, a production-ready Rails 8 starter template for building modern SaaS applications.

**Highlights:**
- 🔐 Complete authentication with 2FA and OAuth
- 💳 Stripe payments and subscriptions
- 👥 Multi-tenant architecture
- 📊 Admin panel with impersonation
- 🔔 Multi-channel notifications
- 🎨 Modern UI with TailwindCSS 4.0
- 🚀 Production-ready with Docker/Kamal
- 📝 AGPL-3.0 licensed
- ✅ 160+ tests with CI/CD

**Stats:**
- 11 models
- 50+ controllers
- 1,500+ lines of documentation
- 90% feature completeness
- Production-ready

---

## How to Use This Changelog

### For Contributors
When contributing, please add your changes to the `[Unreleased]` section under the appropriate category:
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

### For Maintainers
When creating a new release:
1. Move items from `[Unreleased]` to a new version section
2. Add the version number and release date
3. Update the compare links at the bottom
4. Create a git tag for the release

---

## Version History

- **[Unreleased]** - Current development
- **[1.0.0]** - 2025-11-07 - Initial public release

---

[Unreleased]: https://github.com/aliumairdev/rails_saas_kit/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/aliumairdev/rails_saas_kit/releases/tag/v1.0.0
