class TimerSession < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :started_at, presence: true
  validates :timer_type, inclusion: { in: %w[stopwatch pomodoro] }

  scope :active, -> { where(ended_at: nil) }
  scope :recent, -> { order(started_at: :desc) }

  def stop!
    now = Time.current
    update!(ended_at: now, duration_seconds: (now - started_at).to_i)
    task.increment!(:actual_minutes, (duration_seconds / 60.0).ceil)
  end

  def running?
    ended_at.nil?
  end

  def elapsed_seconds
    if running?
      (Time.current - started_at).to_i
    else
      duration_seconds || 0
    end
  end
end
