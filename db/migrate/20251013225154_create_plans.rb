class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :amount, null: false
      t.string :interval, null: false, default: "month"
      t.integer :interval_count, null: false, default: 1
      t.string :currency, null: false, default: "usd"
      t.string :stripe_id
      t.text :description
      t.integer :trial_period_days, default: 14
      t.boolean :hidden, default: false, null: false
      t.jsonb :details, default: {}, null: false
      t.string :contact_url
      t.string :unit_label
      t.boolean :charge_per_unit, default: false

      t.timestamps
    end

    add_index :plans, :stripe_id, unique: true
    add_index :plans, :hidden
  end
end
