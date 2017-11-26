class Category < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :item_claims, through: :items

  validates :name, presence: true

  scope :undeleted, -> { where(deleted_at: nil) }

  # If the category has no items then it's safe to just delete it
  def remove
    items.each(&:remove)

    if items.empty?
      destroy
    else
      update_attributes(deleted_at: Time.zone.now)
    end
  end
end
