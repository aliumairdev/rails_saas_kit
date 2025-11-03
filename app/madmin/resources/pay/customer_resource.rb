class Pay::CustomerResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :processor
  attribute :processor_id
  attribute :default
  attribute :stripe_account
  attribute :deleted_at
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :payment_method_token, index: false
  attribute :braintree_account
  attribute :invoice_credit_balance
  attribute :currency

  # Associations
  attribute :owner
  attribute :charges
  attribute :subscriptions
  attribute :payment_methods
  attribute :default_payment_method

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
