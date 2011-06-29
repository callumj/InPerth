class Place
  include MongoMapper::Document
  
  many    :stubs
  
  key :title, String
  key :lat, String
  key :long, String
  key :address, String
  key :type, String
  key :description, String
end