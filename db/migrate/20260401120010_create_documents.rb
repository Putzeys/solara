class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :documentable_type, null: false
      t.bigint :documentable_id, null: false
      t.string :title, null: false

      t.timestamps
    end

    add_index :documents, [:documentable_type, :documentable_id]
  end
end
