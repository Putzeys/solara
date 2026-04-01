class Task < ApplicationRecord
  belongs_to :user
  belongs_to :channel, optional: true
  belongs_to :weekly_objective, optional: true
  belongs_to :parent_task, class_name: "Task", optional: true
  belongs_to :recurrence_parent, class_name: "Task", optional: true

  has_many :subtasks, class_name: "Task", foreign_key: :parent_task_id, dependent: :destroy
  has_many :recurrence_instances, class_name: "Task", foreign_key: :recurrence_parent_id, dependent: :nullify
  has_many :working_sessions, dependent: :destroy
  has_many :timer_sessions, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy

  has_rich_text :notes

  acts_as_list scope: [ :user_id, :scheduled_date ]

  validates :title, presence: true
  validates :status, inclusion: { in: %w[todo in_progress done cancelled] }
  validates :priority, inclusion: { in: 0..3 }

  scope :for_date, ->(date) { where(scheduled_date: date) }
  scope :backlog, -> { where(scheduled_date: nil) }
  scope :not_done, -> { where.not(status: %w[done cancelled]) }
  scope :done, -> { where(status: "done") }
  scope :ordered, -> { order(:position) }
  scope :top_level, -> { where(parent_task_id: nil) }

  def complete!
    update!(status: "done", completed_at: Time.current)
  end

  def reopen!
    update!(status: "todo", completed_at: nil)
  end

  def done?
    status == "done"
  end

  def backlog?
    scheduled_date.nil?
  end

  def subtask?
    parent_task_id.present?
  end

  def overdue?
    due_date.present? && due_date < Date.current && !done?
  end
end
