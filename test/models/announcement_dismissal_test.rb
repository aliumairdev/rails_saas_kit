require "test_helper"

class AnnouncementDismissalTest < ActiveSupport::TestCase
  def setup
    @dismissal = announcement_dismissals(:one)
  end

  # Associations
  test "should belong to user" do
    assert_respond_to @dismissal, :user
    assert_instance_of User, @dismissal.user
  end

  test "should belong to announcement" do
    assert_respond_to @dismissal, :announcement
    assert_instance_of Announcement, @dismissal.announcement
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @dismissal.valid?
  end

  test "should require unique user per announcement" do
    duplicate = AnnouncementDismissal.new(
      user: @dismissal.user,
      announcement: @dismissal.announcement
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow same user to dismiss different announcements" do
    different_announcement = announcements(:draft)
    dismissal = AnnouncementDismissal.new(
      user: @dismissal.user,
      announcement: different_announcement
    )
    assert dismissal.valid?
  end

  test "should allow different users to dismiss same announcement" do
    different_user = users(:two)
    dismissal = AnnouncementDismissal.new(
      user: different_user,
      announcement: @dismissal.announcement
    )
    assert dismissal.valid?
  end

  # Creation
  test "should create dismissal successfully" do
    user = users(:admin)
    announcement = announcements(:published)

    assert_difference "AnnouncementDismissal.count", 1 do
      AnnouncementDismissal.create!(
        user: user,
        announcement: announcement
      )
    end
  end
end
