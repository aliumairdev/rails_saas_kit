class Pay::ChargeResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :processor_id
  attribute :amount
  attribute :currency
  attribute :application_fee_amount
  attribute :amount_refunded
  attribute :metadata
  attribute :stripe_account
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :paddle_receipt_url
  attribute :stripe_receipt_url
  attribute :payment_method_type
  attribute :brand
  attribute :last4
  attribute :exp_month
  attribute :exp_year
  attribute :email
  attribute :username
  attribute :bank
  attribute :amount_captured
  attribute :invoice_id
  attribute :payment_intent_id
  attribute :period_start
  attribute :period_end
  attribute :line_items
  attribute :subtotal
  attribute :tax
  attribute :discounts
  attribute :total_discount_amounts
  attribute :total_tax_amounts
  attribute :credit_notes
  attribute :refunds

  # Associations
  attribute :customer
  attribute :subscription

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
