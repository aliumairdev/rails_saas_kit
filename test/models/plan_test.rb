require "test_helper"

class PlanTest < ActiveSupport::TestCase
  def setup
    @plan = plans(:pro)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @plan.valid?
  end

  test "should require name" do
    @plan.name = nil
    assert_not @plan.valid?
  end

  test "should require amount" do
    @plan.amount = nil
    assert_not @plan.valid?
  end

  test "should require amount to be non-negative" do
    @plan.amount = -100
    assert_not @plan.valid?
  end

  test "should require interval" do
    @plan.interval = nil
    assert_not @plan.valid?
  end

  test "should validate interval inclusion" do
    @plan.interval = "invalid"
    assert_not @plan.valid?

    %w[day week month year].each do |interval|
      @plan.interval = interval
      assert @plan.valid?
    end
  end

  test "should require currency" do
    @plan.currency = nil
    assert_not @plan.valid?
  end

  # Prefixed IDs
  test "should generate prefixed ID" do
    plan = Plan.create!(
      name: "Test Plan",
      amount: 1000,
      interval: "month",
      interval_count: 1,
      currency: "usd"
    )
    assert plan.prefix_id.start_with?("plan_")
  end

  # Scopes
  test "visible scope should exclude hidden plans" do
    visible_plans = Plan.visible
    assert_not visible_plans.include?(plans(:hidden_plan))
  end

  test "monthly scope should return monthly plans" do
    monthly_plans = Plan.monthly
    assert monthly_plans.all? { |p| p.interval == "month" && p.interval_count == 1 }
  end

  test "yearly scope should return yearly plans" do
    yearly_plans = Plan.yearly
    assert yearly_plans.all? { |p| p.interval == "year" && p.interval_count == 1 }
  end

  # Instance methods
  test "amount_in_dollars should convert cents to dollars" do
    assert_equal 29.00, @plan.amount_in_dollars
  end

  test "interval_name should return formatted interval" do
    @plan.interval_count = 1
    assert_equal "month", @plan.interval_name

    @plan.interval_count = 3
    assert_equal "3 months", @plan.interval_name
  end

  test "feature should return feature value" do
    assert_equal 5000, @plan.feature("max_requests")
    assert_equal 100, @plan.feature(:max_campaigns)
  end

  test "has_feature? should check feature existence" do
    assert @plan.has_feature?("max_requests")
    assert_not @plan.has_feature?("non_existent_feature")
  end

  # Limit helpers
  test "max_requests should return limit" do
    assert_equal 5000, @plan.max_requests
  end

  test "max_campaigns should return limit" do
    assert_equal 100, @plan.max_campaigns
  end

  test "unlimited_requests? should check if unlimited" do
    assert_not @plan.unlimited_requests?

    enterprise = plans(:enterprise)
    assert enterprise.unlimited_requests?
  end

  test "unlimited_campaigns? should check if unlimited" do
    assert_not @plan.unlimited_campaigns?

    enterprise = plans(:enterprise)
    assert enterprise.unlimited_campaigns?
  end
end
