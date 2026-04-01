class CreateChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :channels do |t|
      t.references :user, null: false, foreign_key: true
      t.references :context, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false, default: "#8b5cf6"
      t.string :icon
      t.integer :position, null: false, default: 0
      t.boolean :archived, default: false

      t.timestamps
    end

    add_index :channels, [:user_id, :context_id, :position]
    add_index :channels, [:user_id, :archived]
  end
end
