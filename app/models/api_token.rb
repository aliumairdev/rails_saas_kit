class ApiToken < ApplicationRecord
  # Prefixed IDs
  has_prefix_id :token

  belongs_to :user

  # Validations
  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  # Callbacks
  before_validation :generate_token, on: :create

  # Scopes
  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }
  scope :recently_used, -> { where("last_used_at > ?", 30.days.ago) }

  # Class methods
  def self.find_by_token(plain_token)
    return nil if plain_token.blank?

    hashed_token = hash_token(plain_token)
    active.find_by(token: hashed_token)
  end

  def self.hash_token(plain_token)
    Digest::SHA256.hexdigest(plain_token)
  end

  # Instance methods
  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    !expired?
  end

  def mark_as_used!
    update_column(:last_used_at, Time.current)
  end

  def plain_token
    # This should only be available immediately after creation
    @plain_token
  end

  def reload(*)
    super.tap { @plain_token = nil }
  end

  private

  def generate_token
    return if token.present?

    # Generate a plain token
    @plain_token = SecureRandom.urlsafe_base64(32)

    # Store the hashed version
    self.token = self.class.hash_token(@plain_token)
  end
end
