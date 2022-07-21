class List < ActiveRecord::Base
  has_many :permissions, class_name: 'ListPermission'
  has_many :items

  accepts_nested_attributes_for :permissions

  validates :name, presence: true
end
