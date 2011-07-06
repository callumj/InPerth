require "sinatra"

load "#{File.dirname(__FILE__)}/init.rb"

get '/stub/:tag.:format' do
  classifier = params[:tag]
  
  search_date = 2.weeks.ago
  search_date = Time.at(params[:since]) if params[:since] != nil
  
  stubs = Stub.where(:classifiers => classifier, :created_at.gte => search_date).sort(:created_at.desc).all
  doc = {:time => Time.now.to_i, :count => stubs.count,:data => stubs}
  if ("json".eql?(params[:format]))
    content_type "application/json"
    doc.to_json
  else
    "ERROR"
  end
end