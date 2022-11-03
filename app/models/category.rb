class Category < ActiveRecord::Base
  belongs_to :list
  belongs_to :parent_category, class_name: 'Category', optional: true
  has_many :items, dependent: :destroy
  has_many :item_claims, through: :items

  validates :name, presence: true

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :is_parent, -> { where(parent_category_id: nil) }
  scope :has_parent, -> { where.not(parent_category_id: nil) }

  def <=>(other)
    self[:name] <=> other.name
  end

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
