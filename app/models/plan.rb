class Plan < ApplicationRecord
  # Prefixed IDs
  has_prefix_id :plan

  # Validations
  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: %w[day week month year] }
  validates :interval_count, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :stripe_id, uniqueness: true, allow_nil: true

  # Scopes
  scope :visible, -> { where(hidden: false) }
  scope :monthly, -> { where(interval: "month", interval_count: 1) }
  scope :yearly, -> { where(interval: "year", interval_count: 1) }

  # Instance methods
  def amount_in_dollars
    (amount / 100.0).round(2)
  end

  def interval_name
    interval_count == 1 ? interval : "#{interval_count} #{interval.pluralize}"
  end

  def feature(key)
    details[key.to_s]
  end

  def has_feature?(key)
    feature(key).present?
  end

  # Limit helpers
  def max_requests
    details["max_requests"] || 0
  end

  def max_campaigns
    details["max_campaigns"] || 0
  end

  def unlimited_requests?
    max_requests >= 9999
  end

  def unlimited_campaigns?
    max_campaigns >= 9999
  end
end
