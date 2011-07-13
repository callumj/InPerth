class Place
  include MongoMapper::Document
  
  many    :stubs
  
  key :title, String
  
  #contact
  key :phone, String
  key :address, String
  key :suburb, String
  
  key :description, String
  
  #meta
  key :type, String
  key :urbanspoon_uri, String
  key :google_uri, String
  key :foursquare_uri, String
  key :site_uri, String
  
  #geo
  key :lat, Float
  key :long, Float
end