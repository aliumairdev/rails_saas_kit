class CreateAccountInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :account_invitations do |t|
      t.references :account, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :token, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.jsonb :roles, default: {}, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :account_invitations, :token, unique: true
    add_index :account_invitations, [:account_id, :email], unique: true
    add_index :account_invitations, :expires_at
  end
end
