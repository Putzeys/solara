class Channel < ApplicationRecord
  belongs_to :user
  belongs_to :context, optional: true
  has_many :tasks, dependent: :nullify
  has_many :documents, as: :documentable, dependent: :destroy

  acts_as_list scope: [:user_id, :context_id]

  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :active, -> { where(archived: false) }
  scope :ordered, -> { order(:position) }
end
