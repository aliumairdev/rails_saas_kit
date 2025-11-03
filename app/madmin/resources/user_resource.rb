class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :email
  attribute :encrypted_password
  attribute :reset_password_token
  attribute :reset_password_sent_at
  attribute :remember_created_at
  attribute :sign_in_count, form: false
  attribute :current_sign_in_at
  attribute :last_sign_in_at
  attribute :current_sign_in_ip
  attribute :last_sign_in_ip
  attribute :confirmation_token
  attribute :confirmed_at
  attribute :confirmation_sent_at
  attribute :unconfirmed_email
  attribute :first_name
  attribute :last_name
  attribute :time_zone
  attribute :admin
  attribute :accepted_terms_at
  attribute :accepted_privacy_at
  attribute :announcements_read_at
  attribute :otp_required_for_login
  attribute :otp_secret
  attribute :last_otp_timestep
  attribute :otp_backup_codes
  attribute :preferences
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :name
  attribute :last_activity_at
  attribute :current_status
  attribute :avatar, index: false

  # Associations
  attribute :account_users
  attribute :accounts
  attribute :owned_accounts
  attribute :notifications
  attribute :api_tokens
  attribute :announcement_dismissals
  attribute :dismissed_announcements

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
