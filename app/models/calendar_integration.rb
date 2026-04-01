class CalendarIntegration < ApplicationRecord
  belongs_to :user
  has_many :calendar_events, dependent: :destroy

  encrypts :access_token
  encrypts :refresh_token

  validates :provider, presence: true, uniqueness: { scope: :user_id }

  scope :active, -> { where(active: true) }

  def token_expired?
    token_expires_at.present? && token_expires_at < Time.current
  end
end
