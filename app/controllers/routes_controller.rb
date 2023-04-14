class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index_public]

  def index
    routes_unfiltered = Route.all
    filter_routes_for_query(routes_unfiltered)

    # Create Google Maps URLs for all routes
    @routes_filtered.each do |route|
      route_destinations_ordered = route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }
      update_google_redirect(route_destinations_ordered, route)
    end

    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end

  end

  def index_public

    routes_unfiltered = Route.all
    filter_routes_for_query(routes_unfiltered, true)

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
    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end
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

    # Display warning, if mapbox could not determine route between points
    if @route.google_url == "no_route_found"
      flash.now.alert = "No #{@route.mode} directions found for these destinations!"
    end

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

  def update_mode_cycling
    @route = Route.find(params[:id])
    @route.mode = "cycling"
    @route.save
    redirect_to edit_route_path(@route)
  end

  def update_mode_walking
    @route = Route.find(params[:id])
    @route.mode = "walking"
    @route.save
    redirect_to edit_route_path(@route)
  end

  def update_mode_driving
    @route = Route.find(params[:id])
    @route.mode = "driving"
    @route.save
    redirect_to edit_route_path(@route)
  end

  def updateroutetitle
    @route = Route.find(params[:id])
    @route.update(route_params)
    redirect_to edit_route_path(@route)
  end

  def updateroutecity
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

  def noroute
    @route = Route.find(params[:id])
    @route.update(no_route_params)
  end

  def destroy
    @route = Route.find(params[:id])
    @route.destroy
    flash.notice = "Route successfully deleted!"
    redirect_to routes_path
  end

  private

  def filter_routes_for_query(routes_unfiltered, public = false)

    # Filter for routes with more than 2 destinations
    routes = routes_unfiltered.select { |route| route.route_destinations.length > 2}

    # Filter according to user selection
    if params[:commit].present?

      # Filter for city and shared status first to narrow down results
      @routes_filtered = routes
      if params[:city].present?
        @routes_filtered = @routes_filtered.select { |route| route.city == params[:city]}
      end

      # Only allow public / private filter for private index page
      if public == false
        if params[:private].present? && params[:public].present?
          @routes_filtered = @routes_filtered
        elsif params[:private].present?
          @routes_filtered = @routes_filtered.select { |route| route.shared == false }
        elsif params[:public].present?
          @routes_filtered = @routes_filtered.select { |route| route.shared == true }
        else
          @routes_filtered = []
        end
      # Filter only public routes on public index page
      else
        @routes_filtered = @routes_filtered.select { |route| route.shared == true }
      end
      # Filter for route mode
      user_selected_modes = []
      if params[:walking].present?
        user_selected_modes << "walking"
      end
      if params[:cycling].present?
        user_selected_modes << "cycling"
      end
      if params[:driving].present?
        user_selected_modes << "driving"
      end

      @routes_filtered = @routes_filtered.select { |route| user_selected_modes.include? route.mode }

    else
      if public == false
        @routes_filtered = routes
      else
        @routes_filtered = routes.select { |route| route.shared == true }
      end
    end

  end

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

      route.mode == "cycling" ? travelmode = "bicycling" : travelmode = route.mode
      url = "https://www.google.com/maps/dir/?api=1&origin=#{origin}&destination=#{destination}&travelmode=#{travelmode}"

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

  def no_route_params
    params.require(:route).permit(:google_url)
  end

end
