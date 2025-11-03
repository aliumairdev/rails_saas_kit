class CreateConnectedAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :connected_accounts do |t|
      t.references :owner, polymorphic: true, null: false
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :access_token
      t.string :access_token_secret
      t.string :refresh_token
      t.datetime :expires_at
      t.text :auth

      t.timestamps
    end

    add_index :connected_accounts, [:owner_type, :owner_id]
    add_index :connected_accounts, [:provider, :uid], unique: true
  end
end
