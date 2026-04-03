class AddRolloverCountToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :rollover_count, :integer, default: 0, null: false
  end
end
