class RouteDestinationsController < ApplicationController

  def create
    @route_destination = RouteDestination.new(route_destination_params)
    @route_destination.user = current_user
  end

  def move
    # Only owner of route associated with route destination may edit it
    @route_destination = RouteDestination.find(params[:id])
    authorize @route_destination

    @route_destination.insert_at(params[:position].to_i)
    # @route = Route.find(params[:route_id])
  end

  def destroy
    # Only allow user, who is owner of route destinations route, to destroy route destination
    @route_destination = RouteDestination.find(params[:id])
    authorize @route_destination

    @route_destination.destroy
    flash.notice = "Stop successfully deleted!"
    redirect_back(fallback_location: routes_path, status: :unprocessable_entity)
  end

  private

  def route_destination_params
    params.require(:route_destination).permit(:position)
  end
end
