class Destination < ApplicationRecord
  has_many :route_destinations, dependent: :destroy
end
