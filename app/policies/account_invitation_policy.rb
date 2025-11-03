class AccountInvitationPolicy < ApplicationPolicy
  def index?
    user_is_owner_or_admin?
  end

  def show?
    user_is_owner_or_admin?
  end

  def new?
    user_is_owner_or_admin?
  end

  def create?
    user_is_owner_or_admin?
  end

  def destroy?
    user_is_owner_or_admin?
  end

  def resend?
    user_is_owner_or_admin?
  end

  private

  def user_is_owner_or_admin?
    return false unless user && Current.account

    user.account_owner?(Current.account) || user.account_admin?(Current.account)
  end

  class Scope < Scope
    def resolve
      if user && Current.account
        scope.where(account: Current.account)
      else
        scope.none
      end
    end
  end
end
