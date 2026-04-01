class CreateContexts < ActiveRecord::Migration[8.0]
  def change
    create_table :contexts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false, default: "#6366f1"
      t.string :icon
      t.integer :position, null: false, default: 0
      t.boolean :archived, default: false

      t.timestamps
    end

    add_index :contexts, [ :user_id, :position ]
    add_index :contexts, [ :user_id, :archived ]
  end
end
