class RouteDestinationsController < ApplicationController
  # def index
  #   @route_destinations = RouteDestination.all
  #   @markers = @route_destinations.geocoded.map do |route_destination|
  #     {
  #       lat: route_destination.latitude,
  #       lng: route_destination.longitude
  #     }
  #   end
  # end

  # def show
  #   @route_destination = RouteDestination.find(params[:id])
  # end

  # def new
  #   @route_destination = RouteDestination.new
  # end

  def create
    @route_destination = RouteDestination.new(route_destination_params)
    @route_destination.user = current_user
    # notice: "Stop successfully added!"
  end

  # def edit
  #   @route_destination = RouteDestination.find(params[:id])
  # end

  # def update
  #   @route_destination = RouteDestination.find(params[:id])
  #   @route_destination.update(route_destination_params)
  # end

  def move
    @route_destination = RouteDestination.find(params[:id])
    @route_destination.insert_at(params[:position].to_i)
    @route = Route.find(params[:route_id])
    # @route.destinations
  end

  # def destroy
  #   raise
  #   @route_destination = RouteDestination.find(params[:id])
  #   @route_destination.destroy
  # end

  private

  def route_destination_params
    params.require(:route_destination).permit(:position)
  end
end
