class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :omniauthable,
         omniauth_providers: [:github, :google_oauth2, :facebook, :twitter2]

  # Prefixed IDs
  has_prefix_id :user

  # Name parsing
  has_person_name

  # Multi-tenancy associations
  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users
  has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, dependent: :destroy

  # OAuth Connected Accounts
  has_many :connected_accounts, as: :owner, dependent: :destroy

  # Notifications
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"

  # API Tokens
  has_many :api_tokens, dependent: :destroy

  # Announcements
  has_many :announcement_dismissals, dependent: :destroy
  has_many :dismissed_announcements, through: :announcement_dismissals, source: :announcement

  # Active Storage
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [300, 300]
  end

  # Validations for avatar
  validate :avatar_validation

  def avatar_validation
    return unless avatar.attached?

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end

    acceptable_types = %w[image/png image/jpg image/jpeg image/gif image/webp]
    unless acceptable_types.include?(avatar.blob.content_type)
      errors.add(:avatar, "must be a PNG, JPG, JPEG, GIF, or WEBP")
    end
  end

  # Callbacks
  after_create :create_personal_account

  # Virtual attribute for full name
  # Note: The database has a generated column for this
  def full_name
    name || [first_name, last_name].compact.join(' ').presence || 'User'
  end

  # Get user's personal account
  def personal_account
    accounts.find_by(personal: true)
  end

  # Role-based authorization helpers
  def account_owner?(account)
    account.owner_id == id
  end

  def account_admin?(account)
    return true if account_owner?(account)
    account_user = account_users.find_by(account: account)
    account_user&.admin?
  end

  def account_member?(account)
    accounts.include?(account)
  end

  def account_role(account)
    return "owner" if account_owner?(account)
    account_user = account_users.find_by(account: account)
    return nil unless account_user
    account_user.role_names.first || "member"
  end

  # Notification preferences helpers
  def notification_preference(key)
    preferences.dig("notifications", key.to_s)
  end

  def email_notifications_enabled?(type = nil)
    return false unless preferences.dig("notifications", "email") != false

    if type
      preferences.dig("notifications", type.to_s) != false
    else
      true
    end
  end

  def in_app_notifications_enabled?
    preferences.dig("notifications", "in_app") != false
  end

  # Two-Factor Authentication methods
  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random
  end

  def generate_otp_backup_codes
    codes = 10.times.map { SecureRandom.hex(4) }
    self.otp_backup_codes = codes.join("\n")
    codes
  end

  def otp_code(time = Time.current)
    return nil unless otp_secret.present?
    ROTP::TOTP.new(otp_secret, issuer: "Rails SaaS Kit").at(time)
  end

  def otp_provisioning_uri(email)
    return nil unless otp_secret.present?
    ROTP::TOTP.new(otp_secret, issuer: "Rails SaaS Kit").provisioning_uri(email)
  end

  def verify_otp_code(code, drift: 30)
    return false unless otp_required_for_login?
    return false unless otp_secret.present?

    totp = ROTP::TOTP.new(otp_secret, issuer: "Rails SaaS Kit")
    last_timestep = self.last_otp_timestep

    verified_timestep = totp.verify(code, drift_behind: drift, drift_ahead: drift, after: last_timestep)

    if verified_timestep
      update_column(:last_otp_timestep, verified_timestep)
      true
    else
      false
    end
  end

  def verify_otp_backup_code(code)
    return false unless otp_required_for_login?
    return false unless otp_backup_codes.present?

    codes = otp_backup_codes.split("\n")
    if codes.delete(code)
      update_column(:otp_backup_codes, codes.join("\n"))
      true
    else
      false
    end
  end

  def enable_two_factor!
    generate_otp_secret
    backup_codes = generate_otp_backup_codes
    self.otp_required_for_login = false # Will be enabled after verification
    save
    backup_codes
  end

  def confirm_two_factor!(code)
    if verify_otp_code_for_setup(code)
      update(otp_required_for_login: true)
      true
    else
      false
    end
  end

  def disable_two_factor!
    update(
      otp_required_for_login: false,
      otp_secret: nil,
      otp_backup_codes: nil,
      last_otp_timestep: nil
    )
  end

  private

  def verify_otp_code_for_setup(code)
    return false unless otp_secret.present?
    totp = ROTP::TOTP.new(otp_secret, issuer: "Rails SaaS Kit")
    totp.verify(code, drift_behind: 30, drift_ahead: 30).present?
  end

  def create_personal_account
    account = Account.create!(
      name: full_name,
      owner: self,
      personal: true
    )
    account_users.create!(account: account)
  end
end
