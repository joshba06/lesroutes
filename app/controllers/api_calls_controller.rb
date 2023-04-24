class ApiCallsController < ApplicationController
  before_action :get_user_api_calls

  def add_directions
    directions_count = @user_api_calls.directions
    if @user_api_calls.directions.key?(Date.today.to_s)
      directions_count[Date.today.to_s] += 1
    else
      directions_count[Date.today.to_s] = 1
    end
    @user_api_calls.save
  end

  def add_geocoding
    geocoding_count = @user_api_calls.geocoding
    if @user_api_calls.geocoding.key?(Date.today.to_s)
      geocoding_count[Date.today.to_s] += 1
    else
      geocoding_count[Date.today.to_s] = 1
    end
    @user_api_calls.save
  end

  def add_maploads
    maploads_count = @user_api_calls.maploads
    if @user_api_calls.maploads.key?(Date.today.to_s)
      maploads_count[Date.today.to_s] += 1
    else
      maploads_count[Date.today.to_s] = 1
    end
    @user_api_calls.save
  end

  private

  def get_user_api_calls
    user = Route.find(params[:route_id]).user
    @user_api_calls = ApiCall.where(user: user).first
  end
end
