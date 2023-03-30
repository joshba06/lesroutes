require "open-uri"

puts "Cleaning database"
RouteDestination.destroy_all
Destination.destroy_all
Route.destroy_all
User.destroy_all

puts "Seeding database"

user1 = User.create!(email: "rachel@gmail.com", password: "rachel", first_name: "Rachel", last_name: "Smith", age: 34, location: "London")
puts "Seeding 1 user..."
avatar1 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678277535/rachel2_zsjgbi.png")
user1.photo.attach(io: avatar1, filename: "av1.jpg", content_type: "image/png")

puts "Seeding routes and destinations..."


route1 = Route.create!(title: "London Thames walking tour", user: user1, distance: 5.63, time: 71, city: "London")
routepic1 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/london_zas6np.jpg")
route1.photo.attach(io: routepic1, filename: "rp1.jpg", content_type: "image/jpg")


dest1 = Destination.create!(latitude: 51.508530, longitude: -0.076132, title: "Tower of London", user: user1, city: "London", address: "Tower Hill, London, England EC3N 4AB")
RouteDestination.create!(route: route1, destination: dest1, position: 1)
destpic1 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/toweroflondon_wowyrp.jpg")
dest1.photo.attach(io: destpic1, filename: "dp1.jpg", content_type: "image/jpg")

dest2 = Destination.create!(latitude: 51.507595, longitude: -0.099356, title: "Tate Modern", user: user1, city: "London", address: "53 Bankside, London, England SE1 9TG")
RouteDestination.create!(route: route1, destination: dest2, position: 2)
destpic2 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/toweroflondon_wowyrp.jpg")
dest2.photo.attach(io: destpic2, filename: "dp2.jpg", content_type: "image/jpg")

dest3 = Destination.create!(latitude: 51.503399, longitude: -0.119519, title: "London Eye", user: user1, city: "London", address: "Riverside Building, County Hall, London, England SE1 7PB")
RouteDestination.create!(route: route1, destination: dest3, position: 3)
destpic3 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/londoneye_yctsw7.jpg")
dest3.photo.attach(io: destpic3, filename: "dp3.jpg", content_type: "image/jpg")

dest4 = Destination.create!(latitude: 51.510357, longitude: -0.116773, title: "Big Ben", user: user1, city: "London", address: "Houses of Parliament, Westminster, London, England SW1A 0AA")
RouteDestination.create!(route: route1, destination: dest4, position: 4)
destpic4 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/bigben_vfbvfi.jpg")
dest4.photo.attach(io: destpic4, filename: "dp4.jpg", content_type: "image/jpg")

dest5 = Destination.create!(latitude: 51.501476, longitude: -0.140634, title: "Buckingham Palace", user: user1, city: "London", address: "London, England SW1A 1AA")
RouteDestination.create!(route: route1, destination: dest5, position: 5)
destpic5 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/buckinghampalace_usp6iw.jpg")
dest5.photo.attach(io: destpic5, filename: "dp5.jpg", content_type: "image/jpg")



route2 = Route.create!(title: "Exploring Lisbon", user: user1, distance: 4.8, time: 65, city: "Lisbon")
routepic2 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286626/lisbon_boahbs.jpg")
route2.photo.attach(io: routepic2, filename: "rp2.jpg", content_type: "image/jpg")

dest6 = Destination.create!(latitude: 38.712139, longitude: -9.140246, title: "Convento do Carmo", user: user1, city: "Lisbon", address: "Largo do Carmo, 1200-092 Lisboa, Portugal")
RouteDestination.create!(route: route2, destination: dest6, position: 1)
dest7 = Destination.create!(latitude: 38.711124, longitude: -9.127608, title: "Museu do Fado", user: user1, city: "Lisbon", address: "Largo do Chafariz de Dentro 1, 1100-139 Lisboa, Portugal")
RouteDestination.create!(route: route2, destination: dest7, position: 2)
dest8 = Destination.create!(latitude: 38.710648, longitude: -9.143312, title: "Praça Luís de Camões", user: user1, city: "Lisbon", address: "Praça Luís de Camões, 1200-243 Lisboa, Portugal")
RouteDestination.create!(route: route2, destination: dest8, position: 3)
dest9 = Destination.create!(latitude: 38.713909, longitude: -9.133476, title: "Castelo de São Jorge", user: user1, city: "Lisbon", address: "R. de Santa Cruz do Castelo, 1100-129 Lisboa, Portugal")
RouteDestination.create!(route: route2, destination: dest9, position: 4)

route3 = Route.create!(title: "Paris architecture", user: user1, distance: 8.7, time: 112, city: "Paris")
routepic3 = URI.open("https://res.cloudinary.com/dcuj8efm3/image/upload/v1678286627/eiffeltower_itl1at.png")
route3.photo.attach(io: routepic3, filename: "rp3.jpg", content_type: "image/png")

dest10 = Destination.create!(latitude: 48.858093, longitude: 2.294694, title: "Eiffel Tower", user: user1, city: "Paris", address: "Tour Eiffel, Champ de Mars, 5 Av. Anatole France, 75007 Paris, France")
RouteDestination.create!(route: route3, destination: dest10, position: 1)
dest11 = Destination.create!(latitude: 48.860294, longitude: 2.338629, title: "Musée du Louvre", user: user1, city: "Paris", address: "Rue de Rivoli, 75001 Paris, France")
RouteDestination.create!(route: route3, destination: dest11, position: 2)
dest12 = Destination.create!(latitude: 48.860642, longitude: 2.352245, title: "Centre Pompidou", user: user1, city: "Paris", address: "Place Georges-Pompidou, 75004 Paris, France")
RouteDestination.create!(route: route3, destination: dest12, position: 3)
dest13 = Destination.create!(latitude: 48.887691, longitude: 2.340607, title: "Sacré Coeur de Montmartre", user: user1, city: "Paris", address: "35 Rue du Chevalier de la Barre, 75018 Paris, France")
RouteDestination.create!(route: route3, destination: dest13, position: 4)


puts "Database seeded!"
