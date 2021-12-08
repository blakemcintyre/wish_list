class ItemClaim < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  before_save :clear_blanks

  validates :quantity, presence: true

  private

  def clear_blanks
    self[:notes] = nil unless self[:notes].present?
  end
end
