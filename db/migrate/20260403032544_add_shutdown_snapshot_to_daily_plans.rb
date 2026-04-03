class AddShutdownSnapshotToDailyPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :daily_plans, :completed_snapshot, :jsonb, default: []
    add_column :daily_plans, :rolled_snapshot, :jsonb, default: []
  end
end
