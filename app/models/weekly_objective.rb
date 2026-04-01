class WeeklyObjective < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :nullify

  has_rich_text :notes

  acts_as_list scope: [ :user_id, :week_start_date ]

  validates :title, presence: true
  validates :week_start_date, presence: true
  validates :status, inclusion: { in: %w[active completed abandoned] }

  scope :for_week, ->(date) { where(week_start_date: date.beginning_of_week(:monday)) }
  scope :active, -> { where(status: "active") }
  scope :ordered, -> { order(:position) }
end
