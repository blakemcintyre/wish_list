class ListPermission < ActiveRecord::Base
  belongs_to :list
  belongs_to :user

  validates :list, :user, presence: true
end
