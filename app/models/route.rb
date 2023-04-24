class Route < ApplicationRecord
  validate :user_has_too_many_routes

  belongs_to :user
  has_many :route_destinations, dependent: :destroy
  has_many :destinations, through: :route_destinations

  validates :city, presence: true
  validates :title, presence: true


  private

  def user_has_too_many_routes
    if Route.where(user_id: self.user_id).length >= 10
      errors.add(:too_many, "too many routes")
    end
  end
end
