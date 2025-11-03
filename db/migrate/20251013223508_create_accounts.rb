class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.boolean :personal, default: false, null: false
      t.text :extra_billing_info
      t.string :domain
      t.string :subdomain
      t.string :billing_email
      t.integer :account_users_count, default: 0, null: false

      t.timestamps
    end

    add_index :accounts, :subdomain, unique: true
  end
end
