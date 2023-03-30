class RouteDestination < ApplicationRecord
  acts_as_list scope: :route

  belongs_to :route
  belongs_to :destination

  validates :destination, uniqueness: { scope: :route }
end
