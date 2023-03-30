class Route < ApplicationRecord
  belongs_to :user
  has_many :route_destinations, dependent: :destroy
  has_many :destinations, through: :route_destinations
  has_one_attached :photo
  validates :city, presence: true
  validates :title, presence: true
end
