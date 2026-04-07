class ChangeLlmApiKeyToText < ActiveRecord::Migration[8.0]
  def up
    change_column :users, :llm_api_key, :text
  end

  def down
    change_column :users, :llm_api_key, :string
  end
end
