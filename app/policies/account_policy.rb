# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can see their accounts list
  end

  def show?
    account_member?
  end

  def create?
    true # All authenticated users can create new accounts
  end

  def update?
    account_owner? || account_admin?
  end

  def destroy?
    account_owner? && !record.personal? # Can't delete personal accounts
  end

  def switch?
    account_member?
  end

  def invite_user?
    account_owner? || account_admin?
  end

  def manage_members?
    account_owner? || account_admin?
  end

  def billing?
    account_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Users can only see accounts they're members of
      scope.joins(:account_users).where(account_users: { user_id: user.id })
    end
  end
end
