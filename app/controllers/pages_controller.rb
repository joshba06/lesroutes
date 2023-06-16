class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home]

  def home
    if browser.device.mobile?
      render variants: [:mobile]
    else
      render variants: [:desktop]
    end
  end

  def admin
    route = Route.first
    authorize route

    @routes = Route.all

    api_calls = ApiCall.first

    current_month = Time.new.month
    last_month = (Time.new.month + 1.months)
    @api_usage = {}

    count_current_month = 0
    count_last_month = 0
    api_calls.maploads.each do |date, count|
      date = date.to_date
      if date.year == Time.new.year && date.month == current_month
        count_current_month += count
      elsif date.year == Time.new.year && date.month == last_month
        count_last_month += count
      end
    end
    @api_usage["maploads"] = {
      Time.new.strftime("%B") => count_current_month,
      (Time.new - 1.months).strftime("%B") => count_last_month
    }

    count_current_month = 0
    count_last_month = 0
    api_calls.directions.each do |date, count|
      date = date.to_date
      if date.year == Time.new.year && date.month == current_month
        count_current_month += count
      elsif date.year == Time.new.year && date.month == last_month
        count_last_month += count
      end
    end
    @api_usage["directions"] = {
      Time.new.strftime("%B") => count_current_month,
      (Time.new - 1.months).strftime("%B") => count_last_month
    }

    count_current_month = 0
    count_last_month = 0
    api_calls.geocoding.each do |date, count|
      date = date.to_date
      if date.year == Time.new.year && date.month == current_month
        count_current_month += count
      elsif date.year == Time.new.year && date.month == last_month
        count_last_month += count
      end
    end
    @api_usage["autocomplete"] = {
      Time.new.strftime("%B") => count_current_month,
      (Time.new - 1.months).strftime("%B") => count_last_month
    }


  end

  def export
    route = Route.first
    authorize route

    @routes = Route.all

    export_hash_routes = {}
    @routes.each do |route|
      export_hash_routes[route.title] = {
        city: route.city,
        mode: route.mode,
        stops: route.destinations.length,
        time: route.time,
        distance: route.distance,
        destination_place_ids: route.destinations.each.map { |dest| dest.place_id }
      }
    end

    export_hash_destinations = {}
    Destination.all.each do |destination|
      export_hash_destinations[destination.place_id] =  {
        title: destination.title,
        address: destination.address,
        full_address: destination.full_address,
        latitude: destination.latitude,
        longitude: destination.longitude,
      }
    end

    export_hash_route_destinations = {}
    i = 0
    RouteDestination.all.each do |route_dest|
      export_hash_route_destinations[i] =  {
        route_id: route_dest.route_id,
        destination_id: route_dest.destination_id,
        position: route_dest.position,
      }
      i += 1
    end


    file_routes = "#{Rails.root}/public/routes.json"
    File.open(file_routes, 'w') do |f|
      f.write(export_hash_routes.to_json)
    end

    file_destinations = "#{Rails.root}/public/destinations.json"
    File.open(file_destinations, 'w') do |f|
      f.write(export_hash_destinations.to_json)
    end

    file_route_destinations = "#{Rails.root}/public/route_destinations.json"
    File.open(file_route_destinations, 'w') do |f|
      f.write(export_hash_route_destinations.to_json)
    end

    flash.notice = "Exported routes"
    redirect_to admin_path()

  end
end
