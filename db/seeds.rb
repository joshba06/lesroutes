## Settings for seeds
# Load route information from public/routes.txt (previously exported from database)
use_exported_routes = true

# Settings end

require "open-uri"

puts "Cleaning database"
RouteDestination.destroy_all
Destination.destroy_all
Route.destroy_all
User.destroy_all
ApiCall.destroy_all


puts "Seeding database"
user1 = User.create!(email: "joe@gmail.com", password: "123456", name: "Joe")
user1.confirm
user1.update(admin: true)
user2 = User.create!(email: "rachel@gmail.com", password: "123456", name: "Rachel")
user2.confirm
users = [user2, user2, user2, user2, user1]
puts "Seeding 1 user..."

if use_exported_routes
  file_routes = "#{Rails.root}/public/routes.json"
  file_destinations = "#{Rails.root}/public/destinations.json"
  file_route_destinations = "#{Rails.root}/public/route_destinations.json"


  destinations = JSON.parse(File.read(file_destinations), {:symbolize_names => true})
  route_destinations = JSON.parse(File.read(file_route_destinations), {:symbolize_names => true})
  routes = JSON.parse(File.read(file_routes), {:symbolize_names => true})

  destinations.each do |key, dest_hash|
    puts "Seeding destination: #{dest_hash[:title]}"
    Destination.create!(latitude: dest_hash[:latitude], longitude: dest_hash[:longitude], title: dest_hash[:title], address: dest_hash[:address], full_address: dest_hash[:full_address], place_id: key)
  end

  routes.each do |key, route_hash|
    puts "Seeding route: #{key}"
    route = Route.create!(title: key, user: users.sample, distance: route_hash[:distance], time: route_hash[:time], city: route_hash[:city], mode: route_hash[:mode])

    i = 1
    route_hash[:destination_place_ids].each do |place_id|
      destination = Destination.where(place_id: place_id).first
      puts "Seeding route destination for route: #{route.title} with destination: #{destination.title}"
      RouteDestination.create!(route: route, destination: destination, position: i)
      i += 1
    end
  end
else

  puts "Seeding routes and destinations..."

  route1 = Route.create!(title: "London Sights Walking Tour", user: user1, distance: 8.92, time: 112, city: "London")
  dest1 = Destination.create!(latitude: 51.508530, longitude: -0.076132, title: "Big Ben", address: "Tower Hill, London, England EC3N 4AB")
  dest2 = Destination.create!(latitude: 51.507595, longitude: -0.099356, title: "Tate Modern", address: "53 Bankside, London, England SE1 9TG")
  dest3 = Destination.create!(latitude: 51.503399, longitude: -0.119519, title: "London Eye", address: "Riverside Building, County Hall, London, England SE1 7PB")
  dest4 = Destination.create!(latitude: 51.510357, longitude: -0.116773, title: "Big Ben", address: "Houses of Parliament, Westminster, London, England SW1A 0AA")
  dest5 = Destination.create!(latitude: 51.501476, longitude: -0.140634, title: "Buckingham Palace", address: "London, England SW1A 1AA")

  RouteDestination.create!(route: route1, destination: dest1, position: 1)
  RouteDestination.create!(route: route1, destination: dest2, position: 2)
  RouteDestination.create!(route: route1, destination: dest3, position: 3)
  RouteDestination.create!(route: route1, destination: dest4, position: 4)
  RouteDestination.create!(route: route1, destination: dest5, position: 5)

  route2 = Route.create!(title: "Exploring Lisbon", user: user1, distance: 4.8, time: 65, city: "Lisbon", shared: true, mode: "driving")

  dest6 = Destination.create!(latitude: 38.712139, longitude: -9.140246, title: "Convento do Carmo", address: "Largo do Carmo, 1200-092 Lisboa, Portugal")
  RouteDestination.create!(route: route2, destination: dest6, position: 1)
  dest7 = Destination.create!(latitude: 38.711124, longitude: -9.127608, title: "Museu do Fado", address: "Largo do Chafariz de Dentro 1, 1100-139 Lisboa, Portugal")
  RouteDestination.create!(route: route2, destination: dest7, position: 2)
  dest8 = Destination.create!(latitude: 38.710648, longitude: -9.143312, title: "Praça Luís de Camões", address: "Praça Luís de Camões, 1200-243 Lisboa, Portugal")
  RouteDestination.create!(route: route2, destination: dest8, position: 3)
  dest9 = Destination.create!(latitude: 38.713909, longitude: -9.133476, title: "Castelo de São Jorge", address: "R. de Santa Cruz do Castelo, 1100-129 Lisboa, Portugal")
  RouteDestination.create!(route: route2, destination: dest9, position: 4)

  route3 = Route.create!(title: "Paris architecture", user: user2, distance: 8.7, time: 112, city: "Paris", mode: "cycling")

  dest10 = Destination.create!(latitude: 48.858093, longitude: 2.294694, title: "Eiffel Tower", address: "Tour Eiffel, Champ de Mars, 5 Av. Anatole France, 75007 Paris, France")
  RouteDestination.create!(route: route3, destination: dest10, position: 1)
  dest11 = Destination.create!(latitude: 48.860294, longitude: 2.338629, title: "Musée du Louvre", address: "Rue de Rivoli, 75001 Paris, France")
  RouteDestination.create!(route: route3, destination: dest11, position: 2)
  dest12 = Destination.create!(latitude: 48.860642, longitude: 2.352245, title: "Centre Pompidou", address: "Place Georges-Pompidou, 75004 Paris, France")
  RouteDestination.create!(route: route3, destination: dest12, position: 3)
  dest13 = Destination.create!(latitude: 48.887691, longitude: 2.340607, title: "Sacré Coeur de Montmartre", address: "35 Rue du Chevalier de la Barre, 75018 Paris, France")
  RouteDestination.create!(route: route3, destination: dest13, position: 4)


  # Seed API Calls
  # directions_column = ApiCall.create(directions: {}, maploads: {}, geocoding: {})

  # 10.times do
  #   directions_hash = directions_column.directions
  #   date = Date.today.next_day(rand(90))
  #   if directions_column.directions.key?(date.to_s)
  #     directions_hash[date.to_s] += 1
  #   else
  #     directions_hash[date.to_s] = 1
  #   end
  #   directions_column.save
  # end
  puts "Api Calls Added"

end
ApiCall.create(directions: {}, maploads: {}, geocoding: {})
puts "Database seeded!"
