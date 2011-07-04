require "sinatra"

load "#{File.dirname(__FILE__)}/init.rb"

get '/this_week/:tag' do
  classifier = params[:tag]
  
  stubs = Stub.where(:classifiers => classifier, :created_at.gte => 7.days.ago).all
  {:time => Time.now.to_i, :data => stubs}.to_json
end