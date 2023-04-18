class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # has_one_attached :photo

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  devise :database_authenticatable, :confirmable, :trackable, :registerable,
         :recoverable, :rememberable, :validatable
end
