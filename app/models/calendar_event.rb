class CalendarEvent < ApplicationRecord
  belongs_to :user
  belongs_to :calendar_integration

  validates :google_event_id, :google_calendar_id, :title, :starts_at, :ends_at, presence: true

  scope :for_date, ->(date) { where("starts_at < ? AND ends_at > ?", date.end_of_day, date.beginning_of_day) }
  scope :ordered, -> { order(:starts_at) }
  scope :confirmed, -> { where(status: "confirmed") }

  def duration_minutes
    ((ends_at - starts_at) / 60).round
  end
end
