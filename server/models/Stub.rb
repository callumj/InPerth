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
  key :offline_archive, String
  
  def as_json(options={})
    {:key => self.id, :title => self.title, :uri => self.uri, :desc => self.description, :classifiers => self.classifiers, :tags => self.tags, :time => self.created_at.in_time_zone.to_s, :server_time => self.created_at.to_i, :offline_archive => self.offline_archive, :provider => {:id => self.provider.id, :title => self.provider.title}}
  end
  
  def as_xml(options={})
    {:key => self.id, :title => self.title, :uri => self.uri, :desc => self.description, :classifiers => self.classifiers, :tags => self.tags, :time => self.created_at.in_time_zone.to_s, :provider => {:id => self.provider.id, :title => self.provider.title}}
  end
  
end