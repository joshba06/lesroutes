require "test_helper"

class RoutesControllerTest < ActionDispatch::IntegrationTest


  # LOGGED IN USER
  test "Logged in user should get private index page" do
    @user_guest = User.create(name: "Guest")
    sign_in @user_guest
    get routes_url
    assert_response :success, "Logged in user can access private index page"
  end

  # Not logged in user
  test "Icognito user can access home page" do
    get root_url
    assert_response :success, "Icognito can access home page"
  end

  test "Icognito user cannot get index page" do
    get routes_url
    assert_response :redirect, "Icognito cannot access private index page"
  end

  test "Icognito user cannot get new route page" do
    get new_route_url
    assert_response :redirect, "Icognito cannot get new route page"
  end

  test "Icognito user cannot post new route page" do
    route = Route.new(title: "Something", city: "London")
    post routes_url(route)
    assert_response :redirect, "Icognito cannot post new route page"
  end

  # test "Icognito user cannot get edit route page" do
  #   route = Route.new(title: "Something", city: "London")
  #   route.user_id = 1
  #   route.save
  #   get edit_route_url(route)
  #   assert_response :redirect, "Icognito cannot get edit route page"
  # end



end
