class DailyPlan < ApplicationRecord
  belongs_to :user

  has_rich_text :reflection

  validates :plan_date, presence: true, uniqueness: { scope: :user_id }

  scope :for_date, ->(date) { where(plan_date: date) }

  def tasks
    user.tasks.for_date(plan_date).top_level.ordered
  end

  def completed_tasks
    tasks.done
  end

  def incomplete_tasks
    tasks.not_done
  end

  def total_planned
    tasks.sum(:planned_minutes)
  end

  def total_actual
    tasks.sum(:actual_minutes)
  end
end
