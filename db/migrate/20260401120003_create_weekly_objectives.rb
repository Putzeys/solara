class CreateWeeklyObjectives < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_objectives do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.date :week_start_date, null: false
      t.string :status, default: "active"
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :weekly_objectives, [ :user_id, :week_start_date ]
  end
end
