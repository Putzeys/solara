class WorkingSession < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :starts_at, :ends_at, presence: true
  validate :ends_after_starts

  scope :for_date, ->(date) { where(starts_at: date.beginning_of_day..date.end_of_day) }
  scope :ordered, -> { order(:starts_at) }

  def duration_minutes
    ((ends_at - starts_at) / 60).round
  end

  private

  def ends_after_starts
    return unless starts_at && ends_at
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end
end
