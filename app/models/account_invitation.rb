class AccountInvitation < ApplicationRecord
  # Associations
  belongs_to :account
  belongs_to :invited_by, class_name: "User"

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :token, presence: true, uniqueness: true
  validates :email, uniqueness: { scope: :account_id, message: "has already been invited to this account" }

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expires_at, on: :create

  # Scopes
  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where(accepted_at: nil).where("expires_at <= ?", Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  # Constants
  EXPIRATION_DAYS = 7

  # Instance methods
  def expired?
    accepted_at.nil? && expires_at < Time.current
  end

  def accepted?
    accepted_at.present?
  end

  def pending?
    !expired? && !accepted?
  end

  def accept!(user)
    return false if expired? || accepted?

    transaction do
      # Create or update AccountUser
      account_user = AccountUser.find_or_initialize_by(account: account, user: user)
      account_user.roles = roles
      account_user.save!

      # Mark invitation as accepted
      update!(accepted_at: Time.current)
    end

    true
  end

  def role
    roles["role"] || "member"
  end

  def role=(value)
    self.roles = { "role" => value }
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expires_at
    self.expires_at ||= EXPIRATION_DAYS.days.from_now
  end
end
