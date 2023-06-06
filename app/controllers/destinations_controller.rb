class DestinationsController < ApplicationController
  def create
    @route = Route.find(params[:route_id])

    # Reload page if no input value was given
    if params[:destination][:address] == ""
      flash.notice = "Please enter a location in the search field"
      redirect_to edit_route_path(@route)
    elsif @route.route_destinations.length >= 9
      flash.notice = "You cannot add more than 9 destinations"
      redirect_to edit_route_path(@route)
    else
      dest = Destination.find_by(full_address: params[:destination][:full_address])
      if dest
        @destination = dest
      else
        @destination = Destination.new(destination_params)
        @destination.user = current_user
        @destination.save
      end

      if @route.route_destinations.length.to_i == 0
        index = 1
      else
        index = @route.route_destinations.last.position.to_i + 1
      end

      RouteDestination.create(route: @route, destination: @destination, position: index)

      flash.notice = "Stop successfully added!"
      redirect_to edit_route_path(@route), status: :unprocessable_entity
    end
  end

  def destroy
    @destination = Destination.find(params[:id])
    @destination.destroy
    flash.notice = "Stop successfully deleted!"
    redirect_back(fallback_location: routes_path, status: :unprocessable_entity)
  end

  private

  def destination_params
    params.require(:destination).permit(:title, :longitude, :latitude, :address, :full_address, :place_id)
  end
end
