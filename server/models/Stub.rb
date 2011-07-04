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
  
  def as_json(options={})
    {:title => self.title, :uri => self.uri, :desc => self.description, :tags => tags, :time => self.created_at, :server_time => self.created_at.to_i, :provider => {:id => self.provider.id, :title => self.provider.title}}
  end
  
  def as_xml(options={})
    {:title => self.title, :uri => self.uri, :desc => self.description, :tags => tags, :time => self.created_at, :server_time => self.created_at.to_i, :provider => {:id => self.provider.id, :title => self.provider.title}}
  end
  
end