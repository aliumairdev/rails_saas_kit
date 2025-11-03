# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  protected

  # Helper methods for account-based authorization
  def account
    Current.account
  end

  def account_owner?
    return false unless account
    record.respond_to?(:owner_id) && record.owner_id == user.id
  end

  def account_admin?
    return false unless account
    account_user = user.account_users.find_by(account: account)
    account_user&.admin? || account_owner?
  end

  def account_member?
    return false unless account
    account.member?(user)
  end
end
