class Announcement < ApplicationRecord
  # Rich text
  has_rich_text :content

  # Associations
  has_many :announcement_dismissals, dependent: :destroy
  has_many :dismissed_by_users, through: :announcement_dismissals, source: :user

  # Validations
  validates :kind, presence: true, inclusion: { in: %w[info warning success] }
  validates :title, presence: true

  # Scopes
  scope :published, -> { where("published_at <= ?", Time.current).order(published_at: :desc) }
  scope :draft, -> { where(published_at: nil).order(created_at: :desc) }
  scope :by_kind, ->(kind) { where(kind: kind) }

  # Instance methods
  def published?
    published_at.present? && published_at <= Time.current
  end

  def dismissed_by?(user)
    dismissed_by_users.include?(user)
  end

  def publish!
    update(published_at: Time.current)
  end

  def unpublish!
    update(published_at: nil)
  end
end
