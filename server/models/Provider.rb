class Provider
  include MongoMapper::Document
  
  many :Stubs
  
  key :title, String
  key :uri, String
  key :type, String
  key :classifiers, Array
  key :pipelines, Array
  
  
  def most_recent_date
    first_stub = Stub.where(:provider_id => self._id).sort(:created_at.desc).limit(1).first
    if first_stub != nil
      return first_stub.created_at
    else
      return Time.now-5.week
    end
  end
end