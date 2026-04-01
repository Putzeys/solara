class Context < ApplicationRecord
  belongs_to :user
  has_many :channels, dependent: :nullify

  acts_as_list scope: :user

  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :active, -> { where(archived: false) }
  scope :ordered, -> { order(:position) }
end
