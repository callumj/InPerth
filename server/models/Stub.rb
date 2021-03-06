class Stub
  include MongoMapper::Document
  
  before_save :update_time
  
  belongs_to   :provider
  belongs_to   :place
  
  key :title, String
  key :uri, String
  key :description, String
  key :tags, Array
  key :created_at, Time
  key :updated_at, Time
  key :classifiers, Array
  key :offline_archive, String
  
  def as_json(options={})
    place = {}
    place = {:id => self.place.id, :title => self.place.title} if self.place != nil
    {:key => self.id, :title => self.title, :uri => self.uri, :desc => self.description, :classifiers => self.classifiers, :tags => self.tags, :time => self.created_at.in_time_zone.to_s, :server_time => self.created_at.in_time_zone.to_i, :offline_archive => self.offline_archive, :updated_at => self.updated_at.in_time_zone.to_s, :updated_at_time =>  self.updated_at.in_time_zone.to_i,:provider => {:id => self.provider.id, :title => self.provider.title}, :kind => self.provider.classifiers[0], :place => place}
  end
  
  def as_xml(options={})
    {:key => self.id, :title => self.title, :uri => self.uri, :desc => self.description, :classifiers => self.classifiers, :tags => self.tags, :time => self.created_at.in_time_zone.to_s, :server_time => self.created_at.to_i, :offline_archive => self.offline_archive, :updated_at => self.updated_at.in_time_zone.to_s ,:provider => {:id => self.provider.id, :title => self.provider.title}, :kind => self.provider.classifiers[0]}
  end
  
  def update_time
    self.updated_at = Time.now.in_time_zone
  end
end