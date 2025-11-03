class Account < ApplicationRecord
  # Prefixed IDs
  has_prefix_id :acct

  # Activity tracking
  has_paper_trail

  # Pay integration
  pay_customer stripe_attributes: :stripe_attributes

  # Subscription features concern
  include Subscriptionable

  belongs_to :owner, class_name: "User"

  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :account_invitations, dependent: :destroy

  # Active Storage
  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [300, 300]
  end

  # Validations for logo
  validate :logo_validation

  def logo_validation
    return unless logo.attached?

    if logo.blob.byte_size > 5.megabytes
      errors.add(:logo, "must be less than 5MB")
    end

    acceptable_types = %w[image/png image/jpg image/jpeg image/gif image/webp image/svg+xml]
    unless acceptable_types.include?(logo.blob.content_type)
      errors.add(:logo, "must be a PNG, JPG, JPEG, GIF, WEBP, or SVG")
    end
  end

  # Validations
  validates :name, presence: true
  validates :subdomain, uniqueness: true, allow_blank: true

  # Scopes
  scope :personal, -> { where(personal: true) }
  scope :team, -> { where(personal: false) }

  # Check if user is a member
  def member?(user)
    users.include?(user)
  end

  # Check if user is owner
  def owner?(user)
    owner_id == user.id
  end

  # Subscription helpers
  def subscribed?
    payment_processor&.subscribed? || false
  end

  def on_trial?
    payment_processor&.on_trial? || false
  end

  def subscription
    payment_processor&.subscription
  end

  def pro_plan?
    return false unless subscribed?

    plan = subscription_plan
    return false unless plan

    plan.name.downcase == "pro"
  end

  def can_send_review_request?
    return false unless subscribed?

    within_request_limit?
  end

  private

  def stripe_attributes(pay_customer)
    {
      address: {
        city: owner.city,
        country: owner.country
      },
      metadata: {
        account_id: id,
        account_name: name
      }
    }
  end
end
