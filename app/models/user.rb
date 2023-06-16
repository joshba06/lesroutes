class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :routes, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  devise :database_authenticatable, :trackable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
end
