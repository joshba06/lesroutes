class ApiCall < ApplicationRecord
  # Although these columns are strings, they should be converted to hashes by rails
  serialize :directions, Hash
  serialize :maploads, Hash
  serialize :geocoding, Hash
  
end
