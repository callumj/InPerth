require "sinatra"

load "#{File.dirname(__FILE__)}/init.rb"

get '/this_week/:tag.:format' do
  classifier = params[:tag]
  
  stubs = Stub.where(:classifiers => classifier, :created_at.gte => 2.weeks.ago).all
  doc = {:time => Time.now.to_i, :count => stubs.count,:data => stubs}
  if ("json".eql?(params[:format]))
    content_type "application/json"
    doc.to_json
  elsif ("xml".eql?(params[:format]))
    content_type "text/xml"
    doc.to_xml
  else
    "ERROR"
  end
end