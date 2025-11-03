class CreateAccountUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :account_users do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :roles, default: {}, null: false

      t.timestamps
    end

    add_index :account_users, [:account_id, :user_id], unique: true
  end
end
