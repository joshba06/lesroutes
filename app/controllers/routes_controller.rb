class RoutesController < ApplicationController

  def index
    routes_unfiltered = Route.all
    # Filter for routes with more than 2 destinations
    @routes = routes_unfiltered.select { |route| route.route_destinations.length > 2}

    # Create Google Maps URLs for all routes
    @routes.each do |route|
      route_destinations_ordered = route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }
      update_google_redirect(route_destinations_ordered, route)
    end

    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end

  end

  def show
    @route = Route.find(params[:id])
    @destination = Destination.new
    @route_destinations_ordered = @route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }

    @markers = @route.destinations.geocoded.map do |destination|
      {
        pos: @route.route_destinations.where(destination: destination).first.position,
        lat: destination.latitude,
        lng: destination.longitude,
        marker_html: render_to_string(partial: "marker#{@route.route_destinations.where(destination: destination).first.position}")
      }
    end

    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end
  end

  def new
    @route = Route.new
  end

  def create
    @route = Route.new(route_params)
    @route.user = current_user
    if @route.save
      redirect_to edit_route_path(@route), alert: "You created a new route. Add no more than 9 destinations."
    else
      render :new
    end
  end

  def edit
    @route = Route.find(params[:id])
    @destination = Destination.new

    @route_destinations_ordered = @route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }

    # If the current route has more than 2 destinations, update the routes google maps link
    if @route_destinations_ordered.length >= 2
      update_google_redirect(@route_destinations_ordered, @route)
    else
      @route.google_url = "not_enough_destinations"
      @route.save
    end

    @markers = @route.destinations.geocoded.map do |destination|
      {
        pos: @route.route_destinations.where(destination: destination).first.position,
        lat: destination.latitude,
        lng: destination.longitude,
        marker_html: render_to_string(partial: "marker#{@route.route_destinations.where(destination: destination).first.position}")
      }
    end

    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end

  end

  def updateroutetitle
    @route = Route.find(params[:id])
    @route.update(route_params)
    redirect_to edit_route_path(@route)
  end

  def update
    @route = Route.find(params[:id])
    @route.update(route_params)
    redirect_to route_path(@route)
  end

  # Used for "saving" route on edit page -> Making sure user has at least two destinations
  # If user leaves webpage (since route is still saved in background) index page will filter routes with less than two destinations
  def save
    @route = Route.find(params[:id])
    if @route.route_destinations.length <= 2
      flash.alert = "You need at least 2 destinations to save a route"
      redirect_to edit_route_path(@route)
    else
      redirect_to route_path(@route)
    end
  end

  def move
    @route = Route.find(params[:id])
    @route.update(ajax_params)
  end

  def destroy
    @route = Route.find(params[:id])
    @route.destroy
    flash.notice = "Route successfully deleted!"
    redirect_to routes_path
  end

  private

  def update_google_redirect(route_destinations_ordered, route)

    if route_destinations_ordered.length >= 2

      if route_destinations_ordered.first.title == "Custom location"
        origin = route_destinations_ordered.first.address.gsub(/\s/, "+")
      else
        origin = route_destinations_ordered.first.title.gsub(/\s/, "+")
        origin << "%2C"
        origin << route_destinations_ordered.first.city.gsub(/\s/, "+")
      end

      if route_destinations_ordered.last.title == "Custom location"
        destination = route_destinations_ordered.last.address.gsub(/\s/, "+")
      else
        destination = route_destinations_ordered.last.title.gsub(/\s/, "+")
        destination << "%2C"
        destination << route_destinations_ordered.last.city.gsub(/\s/, "+")
      end

      url = "https://www.google.com/maps/dir/?api=1&origin=#{origin}&destination=#{destination}&travelmode=walking"

      if route_destinations_ordered.length >= 3
        if route_destinations_ordered[1].title == "Custom location"
          waypoint = route_destinations_ordered[1].address.gsub(/\s/, "+")
        else
          waypoint = route_destinations_ordered[1].title.gsub(/\s/, "+")
        end
        url << "&waypoints=#{waypoint}"

        if route_destinations_ordered.length >= 4

          route_destinations_ordered.each_with_index do |destination, index|
            if index >= 2 && index != (route_destinations_ordered.length - 1)
              if destination.title == "Custom location"
                waypoint = destination.address.gsub(/\s/, "+")
              else
                waypoint = destination.title.gsub(/\s/, "+")
              end
              url << "%7C#{waypoint}"
            end
          end
        end
      end
      route.google_url = url
      route.save
    else
      puts "Well, that didnt work"
    end
  end

  def route_params
    params.require(:route).permit(:title, :photo, :city, :distance, :time)
  end

  def ajax_params
    params.require(:route).permit(:distance, :time)
  end
end
