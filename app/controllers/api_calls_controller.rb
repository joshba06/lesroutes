class ApiCallsController < ApplicationController

  def add_directions
    authorize ApiCall
    row = ApiCall.first
    column = row.directions

    if row.directions.key?(Date.today.to_s)
      column[Date.today.to_s] += 1
    else
      column[Date.today.to_s] = 1
    end
    row.save
  end

  def add_geocoding
    authorize ApiCall
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
    authorize ApiCall
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
