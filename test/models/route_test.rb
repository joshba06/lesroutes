require "test_helper"

## Pseudo code for tests

# Should not save without a title
# Should not permit profanity in the title
# Should allow a route to be copied by the user who created it
# Should add a public route to a user if he or she "copies" it
# Should not save without a user assigned to it
# Should not save without a city
# Should not save without a "shared" property
# Should not save without a "likes" property
# Should not save unless city exists (in the world)
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

  test "should not save article without title" do
    article = Article.new
    assert_not article.save
  end

end
