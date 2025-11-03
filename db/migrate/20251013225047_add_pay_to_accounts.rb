class AddPayToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :processor, :string
    add_index :accounts, :processor
    add_column :accounts, :processor_id, :string
    add_index :accounts, :processor_id, unique: true
  end
end
