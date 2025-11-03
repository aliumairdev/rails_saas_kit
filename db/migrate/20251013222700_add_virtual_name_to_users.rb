class AddVirtualNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :virtual, type: :string, as: "first_name || ' ' || COALESCE(last_name, '')", stored: true
  end
end
