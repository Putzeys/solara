class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :contexts, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :weekly_objectives, dependent: :destroy
  has_many :daily_plans, dependent: :destroy
  has_many :working_sessions, dependent: :destroy
  has_many :timer_sessions, dependent: :destroy
  has_many :calendar_integrations, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :documents, dependent: :destroy

  encrypts :llm_api_key

  before_create :generate_api_token

  def obsidian_configured?
    llm_endpoint.present? && llm_model.present? && obsidian_vault_path.present? && Dir.exist?(obsidian_vault_path.to_s)
  end

  private

  def generate_api_token
    self.api_token ||= SecureRandom.hex(32)
  end
end
