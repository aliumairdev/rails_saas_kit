require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  def setup
    @announcement = announcements(:published)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @announcement.valid?
  end

  test "should require title" do
    @announcement.title = nil
    assert_not @announcement.valid?
    assert_includes @announcement.errors[:title], "can't be blank"
  end

  test "should require kind" do
    @announcement.kind = nil
    assert_not @announcement.valid?
    assert_includes @announcement.errors[:kind], "can't be blank"
  end

  test "should validate kind inclusion" do
    @announcement.kind = "invalid"
    assert_not @announcement.valid?
    assert_includes @announcement.errors[:kind], "is not included in the list"

    %w[info warning success].each do |valid_kind|
      @announcement.kind = valid_kind
      assert @announcement.valid?, "#{valid_kind} should be a valid kind"
    end
  end

  # Associations
  test "should have many announcement_dismissals" do
    assert_respond_to @announcement, :announcement_dismissals
  end

  test "should have many dismissed_by_users" do
    assert_respond_to @announcement, :dismissed_by_users
  end

  test "should have rich text content" do
    assert_respond_to @announcement, :content
    @announcement.content = "<p>Test content</p>"
    assert_includes @announcement.content.to_s, "Test content"
  end

  # Scopes
  test "published scope should return published announcements" do
    published = Announcement.published
    assert published.all? { |a| a.published? }
    assert_includes published, announcements(:published)
    assert_not_includes published, announcements(:draft)
  end

  test "draft scope should return unpublished announcements" do
    drafts = Announcement.draft
    assert drafts.all? { |a| a.published_at.nil? }
    assert_includes drafts, announcements(:draft)
    assert_not_includes drafts, announcements(:published)
  end

  test "by_kind scope should filter by kind" do
    info_announcements = Announcement.by_kind("info")
    assert info_announcements.all? { |a| a.kind == "info" }
  end

  # Instance methods
  test "published? should return true for published announcements" do
    @announcement.published_at = 1.day.ago
    assert @announcement.published?
  end

  test "published? should return false for announcements published in the future" do
    @announcement.published_at = 1.day.from_now
    assert_not @announcement.published?
  end

  test "published? should return false for announcements with nil published_at" do
    @announcement.published_at = nil
    assert_not @announcement.published?
  end

  test "dismissed_by? should return true if user dismissed announcement" do
    # User one has already dismissed published announcement in fixtures
    user = users(:one)
    assert @announcement.dismissed_by?(user), "User one should have dismissed the announcement (from fixtures)"
  end

  test "dismissed_by? should return false if user has not dismissed announcement" do
    # Admin user has not dismissed any announcements
    user = users(:admin)
    assert_not @announcement.dismissed_by?(user)
  end

  test "publish! should set published_at to current time" do
    draft = announcements(:draft)
    assert_nil draft.published_at

    draft.publish!
    assert_not_nil draft.published_at
    assert draft.published_at <= Time.current
  end

  test "unpublish! should set published_at to nil" do
    assert_not_nil @announcement.published_at

    @announcement.unpublish!
    assert_nil @announcement.reload.published_at
  end

  # Dependent destroy
  test "destroying announcement should destroy associated dismissals" do
    # Create a new announcement to avoid conflicts with existing dismissals in fixtures
    announcement = Announcement.create!(
      title: "Test Announcement",
      kind: "info",
      published_at: Time.current
    )
    user = users(:admin)
    dismissal = AnnouncementDismissal.create!(announcement: announcement, user: user)

    assert_difference "AnnouncementDismissal.count", -1 do
      announcement.destroy
    end
  end
end
