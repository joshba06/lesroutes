class RoutesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index_public, :show]
  before_action :check_number_of_api_calls

  def index
    routes_unfiltered = Route.all.select { |route| route.user == current_user}
    filter_routes_for_query(routes_unfiltered)
    render_device_specific_view
  end

  def index_public
    routes_unfiltered = Route.all
    filter_routes_for_query(routes_unfiltered, true)
    render_device_specific_view
  end

  def show
    # If limit of google api calls is reached, redirect to index or public index page
    if @website_offline && request.referrer.include?("routes/public")
      redirect_to public_routes_path, alert: "We are currently experiencing a very large number of visits. Please check back at the beginning of next month. You can still start navigation from here"
    elsif @website_offline
      redirect_to myroutes_path, alert: "We are currently experiencing a very large number of visits. Please check back at the beginning of next month. You can still start navigation from here"
    else
      @route = Route.find(params[:id])
      @destination = Destination.new
      @route_destinations_ordered = @route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }

      @markers_hash = {}
      @route.destinations.map do |destination|
        @markers_hash[@route.route_destinations.where(destination: destination).first.position] =
        {
          lat: destination.latitude,
          lng: destination.longitude,
          place_id: destination.place_id
        }
      end

      render_device_specific_view
    end
  end

  def new
    @route = Route.new
    render_device_specific_view
  end

  def create
    @route = Route.new(route_params)
    @route.user = current_user
    if @route.save
      redirect_to edit_route_path(@route), notice: "You created a new route. Add no more than 9 destinations."
    else
      if @route.errors.where(:too_many).length != 0
        redirect_to routes_path, alert: "You can only have 10 routes assigned to your account."
      else
        render_device_specific_view("new")
      end
    end
  end

  def edit
    @route = Route.find(params[:id])
    @destination = Destination.new
    @route_destinations_ordered = @route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }

    @markers_hash = {}
    @route.destinations.map do |destination|
      position = @route.route_destinations.where(destination: destination).first.position
      @markers_hash[position] =
      {
        lat: destination.latitude,
        lng: destination.longitude,
        place_id: destination.place_id,
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
    flash.notice = "Route mode changed to #{@route.mode}"
    redirect_to edit_route_path(@route)
  end

  def update_mode_walking
    @route = Route.find(params[:id])
    @route.mode = "walking"
    @route.save
    flash.notice = "Route mode changed to #{@route.mode}"
    redirect_to edit_route_path(@route)
  end

  def update_mode_driving
    @route = Route.find(params[:id])
    @route.mode = "driving"
    @route.save
    flash.notice = "Route mode changed to #{@route.mode}"
    redirect_to edit_route_path(@route)
  end

  def updateroutetitle
    @route = Route.find(params[:id])
    @route.update(route_params)
    flash.notice = "Route title updated"
    redirect_to edit_route_path(@route)
  end

  def updateroutecity
    @route = Route.find(params[:id])
    @route.update(route_params)
    flash.notice = "Route city updated"
    redirect_to edit_route_path(@route)
  end

  def update
    @route = Route.find(params[:id])
    @route.update(route_params)
    redirect_to route_path(@route)
  end

  def share_route
    @route = Route.find(params[:id])
    flash.alert = "#{@route.title} is now publicly available"
    @route.update(ajax_params)
  end

  def stop_sharing_route
    @route = Route.find(params[:id])
    flash.alert = "Stopped sharing #{@route.title} with community."
    @route.update(ajax_params)
  end

  def save
    @route = Route.find(params[:id])
    if @route.route_destinations.length < 2
      flash.notice = "You need at least 2 destinations to save a route"
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

  def update_google_url
    route = Route.find(params[:id])
    route_destinations_ordered = route.route_destinations.order(position: :asc).map { |route_destination| route_destination.destination }

    if route_destinations_ordered.length >= 2

      origin = route_destinations_ordered.first.title
      origin_place_id = route_destinations_ordered.first.place_id

      destination = route_destinations_ordered.last.title
      destination_place_id = route_destinations_ordered.last.place_id

      route.mode == "cycling" ? travelmode = "bicycling" : travelmode = route.mode
      url = "https://www.google.com/maps/dir/?api=1&origin=#{origin}&origin_place_id=#{origin_place_id}&destination=#{destination}&destination_place_id=#{destination_place_id}&travelmode=#{travelmode}"

      if route_destinations_ordered.length >= 3
        waypoint_place_ids = []

        waypoint = route_destinations_ordered[1].title
        waypoint_place_ids << route_destinations_ordered[1].place_id

        url << "&waypoints=#{waypoint}"

        if route_destinations_ordered.length >= 4
          route_destinations_ordered.each_with_index do |destination, index|
            if index >= 2 && index != (route_destinations_ordered.length - 1)
              unless destination.place_id.nil?
                waypoint = destination.title
                waypoint_place_ids << destination.place_id
                url << "%7C#{waypoint}"
              end
            end
          end
        end

        url << "&waypoint_place_ids="
        waypoint_place_ids.each { |id| url << "#{id}%7C"}
      end
    else
      url = "https://www.lesroutes.co.uk/#{route.id}"
      flash.notice = "No #{route.mode} directions found for these destinations!"
    end

    route.google_url = url
    route.save

  end

  private

  def render_device_specific_view(view = false)
    if view
      if browser.device.mobile?
        render "#{view}", variants: [:mobile]
      else
        render "#{view}", variants: [:desktop]
      end
    else
      if browser.device.mobile?
        render variants: [:mobile]
      else
        render variants: [:desktop]
      end
    end
  end

  def check_number_of_api_calls
    current_month_startdate = Date.today.beginning_of_month
    current_month_enddate = Date.today.end_of_month

    # Count directions API calls
    direction_calls = 0
    directions_call_hash = ApiCall.first.directions
    directions_call_hash.each do |date, calls|
      direction_calls += calls if date.to_s >= current_month_startdate.to_s
    end

    # Count maploads API calls
    maploads_calls = 0
    maploads_call_hash = ApiCall.first.maploads
    maploads_call_hash.each do |date, calls|
      maploads_calls += calls if date.to_s >= current_month_startdate.to_s
    end

    if maploads_calls >= 47500 || direction_calls >= 95000
      @website_offline = true
    end
  end

  def filter_routes_for_query(routes_unfiltered, public = false)

    # Filter for routes with more than 2 destinations
    routes = routes_unfiltered.select { |route| route.route_destinations.length >= 2}

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

    # Sort routes alphabetically
    @routes_filtered = @routes_filtered.sort { |a, b| a.title <=> b.title}

  end

  def route_params
    params.require(:route).permit(:title, :city, :distance, :time)
  end

  def ajax_params
    params.require(:route).permit(:distance, :time, :shared)
  end

end
