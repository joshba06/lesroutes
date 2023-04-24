class ApiCallsController < ApplicationController

  def add_directions
    directions_column = ApiCall.first
    directions_count = directions_column.directions

    if directions_column.directions.key?(Date.today.to_s)
      directions_count[Date.today.to_s] += 1
    else
      directions_count[Date.today.to_s] = 1
    end
    directions_column.save
  end

  def add_geocoding
    geocoding_column = ApiCall.first
    geocoding_count = geocoding_column.geocoding
    if geocoding_column.geocoding.key?(Date.today.to_s)
      geocoding_count[Date.today.to_s] += 1
    else
      geocoding_count[Date.today.to_s] = 1
    end
    geocoding_column.save
  end

  def add_maploads
    maploads_column = ApiCall.first
    maploads_count = maploads_column.maploads
    if maploads_column.maploads.key?(Date.today.to_s)
      maploads_count[Date.today.to_s] += 1
    else
      maploads_count[Date.today.to_s] = 1
    end
    maploads_column.save
  end
end
