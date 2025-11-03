class AccountUser < ApplicationRecord
  belongs_to :account, counter_cache: :account_users_count
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: { scope: :account_id }

  # Available roles
  ROLES = %w[owner admin member].freeze

  # Role helpers
  def admin?
    has_role?("admin")
  end

  def owner?
    has_role?("owner")
  end

  def member?
    has_role?("member")
  end

  def has_role?(role_name)
    roles[role_name.to_s] == true
  end

  def add_role(role_name)
    return false unless ROLES.include?(role_name.to_s)
    self.roles = roles.merge(role_name.to_s => true)
    save
  end

  def remove_role(role_name)
    return false unless ROLES.include?(role_name.to_s)
    self.roles = roles.except(role_name.to_s)
    save
  end

  def role_names
    roles.select { |_k, v| v == true }.keys
  end
end
