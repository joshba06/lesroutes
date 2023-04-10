require "test_helper"

## Pseudo code for tests


# Should not permit profanity in the title
# Should allow a route to be copied by the user who created it
# Should add a public route to a user if he or she "copies" it

# Should have a default "mode" value of "walking"
# Should only allow mode values "walking", "cycling", "driving"
# Should have a default "time" and "distance" value of 0
# Should have a default "google_url" value of nil
# Should have a default "shared" value of false
# Should permit "shared" to be true or false
# Should have a default "likes" value of 0

# Should delete all its route destinations if a route is deleted

# Shall only be editable by user, who created it
# Shall only be removable by user, who created it
# Shall not be "likeable" by user, who created it

# Shall change a routes google_url when destinations are added or changed

# Cannot have more than 9 route_destinations
# May have the same route_destinations multiple times

# User should not have more than 25 routes
# Should delete a destination, if no such route_destination exists


class RouteTest < ActiveSupport::TestCase

  # it 'should take one parameter' do
  #   initialize_parameters_count = Chicken.allocate.method(:initialize).arity
  #   expect(initialize_parameters_count).to eq 1
  # end

  # Checking default values
  # route = Route.new

  # test "should have a title" do
  #   assert_respond_to(route, :title, ["msg"] )
  #   assert_respond_to(route.title, NilClass, "Route has 'title' value of type string" )
  #   # expect(Route.new).to respond_to :title
  #   # expect(new_route.age).to be_a :string
  # end




  # test "should not save route without a title" do
  #   route = Route.new
  #   assert_not route.save, "Cannot save route without a title"
  # end

  # test "should not save route without a city" do
  #   route = Route.new(title: "Some title")
  #   assert_not route.save, "Cannot save route without a city"
  # end


  # it "OrangeTree constructor (initialize method) should not take any parameters" do
  #   initialize_parameters_count = OrangeTree.allocate.method(:initialize).arity
  #   expect(initialize_parameters_count).to eq 0
  # end

  # it "should have an age" do
  #   expect(orange_tree).to respond_to :age
  #   expect(orange_tree.age).to be_a Integer
  # end

  # it "should be 0 years old when created" do
  #   expect(orange_tree.age).to eq 0
  # end

  # it "should have a height" do
  #   expect(orange_tree).to respond_to :height
  #   expect(orange_tree.height).to be_a Integer
  # end

  # it "should measure 0 meters when 0 years old" do
  #   expect(orange_tree.height).to eq 0
  # end

  # it "should have fruits" do
  #   expect(orange_tree).to respond_to :fruits
  #   expect(orange_tree.fruits).to be_a Integer
  # end

  # it "should have 0 fruits when 0 years old" do
  #   expect(orange_tree.fruits).to eq 0
  # end

  # it "should let us check whether the tree is dead or alive" do
  #   expect(orange_tree).to respond_to(:dead?)
  #   expect(orange_tree.dead?).to eq(false)
  # end

  # it "should have an `one_year_passes!` method to simulate a year pass




  # Should not save without a user assigned to it
# Should not save without a city
# Should not save without a "shared" property
# Should not save without a "likes" property
# Should not save unless city exists (in the world)

end
