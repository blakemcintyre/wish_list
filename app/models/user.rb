class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :categories
  has_many :items
  has_many :item_claims

  has_many :list_permissions
  has_many :lists, through: :list_permissions
end
