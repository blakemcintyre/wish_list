class Category < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent_category, class_name: 'Category'
  has_many :items, dependent: :destroy
  has_many :item_claims, through: :items

  validates :name, presence: true

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :is_parent, -> { where(parent_category_id: nil) }
  scope :has_parent, -> { where.not(parent_category_id: nil) }

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
