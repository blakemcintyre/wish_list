class Category < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :item_claims, through: :items

  validates :name, presence: true

  scope :undeleted, -> { where(deleted_at: nil) }

  # If the category has no items then it's safe to just delete it
  def remove
    items.each(&:remove)

    if items.any?(&:persisted?)
      touch(:deleted_at)
    else
      destroy
    end
  end
end
