class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  after_action :verify_authorized, except: [:home, :index_public], unless: :skip_pundit?
  after_action :verify_policy_scoped, only: [:index], unless: :skip_pundit?


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
