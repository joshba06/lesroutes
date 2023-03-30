class Destination < ApplicationRecord
  belongs_to :user
  has_many :route_destinations, dependent: :destroy
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
  # after_validation :latitude?
  has_one_attached :photo

  # def latitude?
  #   if latitude.nil?
  #     after_validation :geocode, if: :will_save_change_to_address?
  #   end
  # end
end
