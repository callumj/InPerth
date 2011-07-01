class Stub
  include MongoMapper::Document
  
  belongs_to   :provider
  belongs_to   :place
  
  key :title, String
  key :uri, String
  key :description, String
  key :tags, Array
  key :created_at, Time
  key :classifiers, Array
end