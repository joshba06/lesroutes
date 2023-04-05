class RouteDestinationsController < ApplicationController

  def create
    @route_destination = RouteDestination.new(route_destination_params)
    @route_destination.user = current_user
    # notice: "Stop successfully added!"
  end

  def move
    @route_destination = RouteDestination.find(params[:id])
    @route_destination.insert_at(params[:position].to_i)
    @route = Route.find(params[:route_id])
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
