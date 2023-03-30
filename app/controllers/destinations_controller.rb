class DestinationsController < ApplicationController
  def index
    @destinations = Destination.all
  end

  def show
    @destination = Destination.find(params[:id])
  end

  def new
    @destination = Destination.new
  end

  def create
    @route = Route.find(params[:route_id])

    # Reload page if no input value was given
    if params[:destination][:address] == ""
      flash.alert = "Please enter a location in the search field"
      redirect_to edit_route_path(@route), status: :unprocessable_entity

    elsif @route.route_destinations.length >= 9
      flash.alert = "You cannot add more than 9 destinations"
      redirect_to edit_route_path(@route), status: :unprocessable_entity

    else
      dest = Destination.find_by(address: params[:destination][:address])
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

  def edit
    @destination = Destination.find(params[:id])
  end

  def update
    @destination = Destination.find(params[:id])
    @destination.update(destination_params)
  end

  def destroy
    @destination = Destination.find(params[:id])
    @destination.destroy
    flash.notice = "Stop successfully deleted!"
    redirect_back(fallback_location: routes_path, status: :unprocessable_entity)
  end

  private

  def destination_params
    params.require(:destination).permit(:title, :longitude, :latitude, :address, :city)
  end
end
