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

  before_create :generate_api_token

  private

  def generate_api_token
    self.api_token ||= SecureRandom.hex(32)
  end
end
