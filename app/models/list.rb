class List < ActiveRecord::Base
  has_many :permissions, class_name: 'ListPermission', dependent: :destroy
  has_many :users, through: :permissions
  has_many :items, dependent: :destroy
  has_many :categories, dependent: :destroy

  accepts_nested_attributes_for :permissions, allow_destroy: true

  validates :name, presence: true
  validates :permissions, presence: { message: 'At least one user must be selected' }
end
