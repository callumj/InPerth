class Place
  include MongoMapper::Document
  
  before_save :update_time
  
  many    :stubs
  
  key :title, String
  key :created_at, Time
  key :updated_at, Time
  
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
  key :tags, Array
  
  #geo
  key :lat, Float
  key :long, Float
  
  def update_time
    self.created_at = Time.now if self.created_at == nil
    self.updated_at = Time.now
  end
  
  def as_json(options={})
    all_keys = self.class.keys.keys
    ret_hash = Hash.new
    
    all_keys.each {|key| ret_hash[key] = self[key] unless key.empty?}
    
    ret_hash["stubs"] = []
    self.stubs.each {|stub| ret_hash["stubs"] << stub._id}
    
    ret_hash
  end
end