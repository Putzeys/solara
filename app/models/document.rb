class Document < ApplicationRecord
  belongs_to :user
  belongs_to :documentable, polymorphic: true

  has_rich_text :body
  has_many_attached :files

  validates :title, presence: true
  validates :documentable_type, inclusion: { in: %w[Channel Task] }
end
