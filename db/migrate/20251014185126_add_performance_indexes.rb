class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Accounts indexes
    add_index :accounts, :personal unless index_exists?(:accounts, :personal)
    add_index :accounts, :created_at unless index_exists?(:accounts, :created_at)

    # Notifications indexes
    add_index :noticed_notifications, :created_at unless index_exists?(:noticed_notifications, :created_at)
  end
end
