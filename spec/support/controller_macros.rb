module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryBot.create(:admin) # Using factory bot as an example
    end
  end

  def login_user
    before(:each) do
      p "Running in environemnt: #{ENV['RAILS_ENV']}"
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      user.confirm
      p "Successfully confirmed user"
      sign_in user
    end
  end

  def create_route_w_destinations
    before(:each) do
      user = User.last
      route1 = Route.create!(title: "London Thames walking tour", user: user, distance: 5.63, time: 71, city: "London")
      dest1 = Destination.create!(latitude: 51.508530, longitude: -0.076132, title: "Tower of London", address: "Tower Hill, London, England EC3N 4AB")
      RouteDestination.create!(route: route1, destination: dest1, position: 1)
      dest2 = Destination.create!(latitude: 51.507595, longitude: -0.099356, title: "Tate Modern", address: "53 Bankside, London, England SE1 9TG")
      RouteDestination.create!(route: route1, destination: dest2, position: 2)
      dest3 = Destination.create!(latitude: 51.503399, longitude: -0.119519, title: "London Eye", address: "Riverside Building, County Hall, London, England SE1 7PB")
      RouteDestination.create!(route: route1, destination: dest3, position: 3)
      dest4 = Destination.create!(latitude: 51.510357, longitude: -0.116773, title: "Big Ben", address: "Houses of Parliament, Westminster, London, England SW1A 0AA")
      RouteDestination.create!(route: route1, destination: dest4, position: 4)
      dest5 = Destination.create!(latitude: 51.501476, longitude: -0.140634, title: "Buckingham Palace", address: "London, England SW1A 1AA")
      RouteDestination.create!(route: route1, destination: dest5, position: 5)

      # Seed api calls
      ApiCall.create()
      apis = %w(directions maploads geocoding)
      10.times do
        api = apis.sample
        row = ApiCall.first

        if api == "directions"
          column = row.directions
        elsif api == "maploads"
          column = row.maploads
        else
          column = row.geocoding
        end

        if column.key?(Date.today.to_s)
          column[Date.today.to_s] += 1
        else
          column[Date.today.to_s] = 1
        end
        row.save
      end

    end
  end


end
