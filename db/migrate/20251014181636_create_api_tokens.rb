class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :name, null: false
      t.jsonb :metadata, default: {}, null: false
      t.boolean :transient, default: false, null: false
      t.datetime :last_used_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :api_tokens, :token, unique: true
    add_index :api_tokens, :last_used_at
    add_index :api_tokens, :expires_at
  end
end
