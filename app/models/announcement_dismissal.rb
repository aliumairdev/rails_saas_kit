class AnnouncementDismissal < ApplicationRecord
  belongs_to :user
  belongs_to :announcement

  validates :user_id, uniqueness: { scope: :announcement_id }
end
