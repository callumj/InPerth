class Meta
  include MongoMapper::Document
  
  before_save :update_time
  
  key :name, String
  key :created_at, Time
  key :updated_at, Time
  key :meta, Hash
  
  
  def update_time
    self.created_at = Time.now if self.created_at == nil
    self.updated_at = Time.now
  end
end