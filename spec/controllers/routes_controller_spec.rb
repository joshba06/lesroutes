require "rails_helper"
require_relative "../support/devise"

include ActionView::Helpers

RSpec.describe RoutesController, :type => :controller do

  # describe "GET /" do
  #   login_user
  #   create_route_w_destinations

  #   context "from login user" do
  #     render_views

  #     it "should return 200:OK" do
  #       # get :index, variants: [:mobile]
  #       # session[:mobile_param] == "1"
  #       get :index
  #       p browser.device.mobile?
  #       # expect(response).to have_http_status(:success)
  #       expect(response).to be_successful
  #       expect(response).to render_template("success")
  #     end
  #   end
  # end

  # before(:all) do
  #   @user1 = create(:user)
  #   sign_in @user1
  # end

  # it "is valid with valid attributes" do
  #   expect(@user1).to be_valid
  # end

end
