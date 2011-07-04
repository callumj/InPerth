require "sinatra"

load "#{File.dirname(__FILE__)}/init.rb"

get '/this_week/:tag.:format' do
  classifier = params[:tag]
  
  stubs = Stub.where(:classifiers => classifier, :created_at.gte => 7.days.ago).all
  if ("json".eql?(params[:format]))
    content_type "application/json"
    {:time => Time.now.to_i, :data => stubs}.to_json
  elsif ("xml".eql?(params[:format]))
    content_type "text/xml"
    {:time => Time.now.to_i, :data => stubs}.to_xml
  else
    "hi"
  end
end