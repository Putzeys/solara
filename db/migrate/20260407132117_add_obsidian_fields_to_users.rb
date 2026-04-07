class AddObsidianFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :llm_endpoint, :string
    add_column :users, :llm_api_key, :string
    add_column :users, :llm_model, :string
    add_column :users, :obsidian_vault_path, :string
    add_column :users, :obsidian_prompt_template, :text
    add_column :users, :obsidian_response_format, :string, default: "json"
  end
end
