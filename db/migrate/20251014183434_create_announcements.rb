class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.string :kind, null: false
      t.string :title, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :announcements, :published_at
    add_index :announcements, :kind
  end
end
