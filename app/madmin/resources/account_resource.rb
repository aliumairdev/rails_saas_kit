class AccountResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :personal
  attribute :extra_billing_info
  attribute :domain
  attribute :subdomain
  attribute :billing_email
  attribute :account_users_count, form: false
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :processor
  attribute :processor_id
  attribute :logo, index: false

  # Associations
  attribute :versions
  attribute :pay_customers
  attribute :charges
  attribute :subscriptions
  attribute :payment_processor
  attribute :owner
  attribute :account_users
  attribute :users
  attribute :account_invitations

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  # def self.display_name(record) = record.name

  # Customize the default sort column and direction.
  # def self.default_sort_column = "created_at"
  #
  # def self.default_sort_direction = "desc"
end
