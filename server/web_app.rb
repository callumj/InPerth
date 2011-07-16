require 'thin'
require "sinatra"

load "#{File.dirname(__FILE__)}/init.rb"

get '/stub/:tag.:format' do
  classifier = params[:tag]
  
  search_date = 2.weeks.ago.in_time_zone
  search_date = Time.at(params[:since].to_i).in_time_zone if params[:since] != nil
  
  stubs = []
  
  if "all".eql?(classifier)
    stubs = Stub.where(:created_at.gt => search_date).sort(:created_at.desc).all
  else
    stubs = Stub.where(:classifiers => classifier, :created_at.gt => search_date).sort(:created_at.desc).all
  end
  doc = {:time => Time.now.to_i, :count => stubs.count,:data => stubs}
  if ("json".eql?(params[:format]))
    content_type "application/json"
    doc.to_json
  else
    "ERROR"
  end
end

get '/place/:tag.:format' do
  classifier = params[:tag]
  
  search_date = Time.at(0).in_time_zone #SINCE THE BEGINNING OF TIME (Unix)
  search_date = Time.at(params[:since].to_i).in_time_zone if params[:since] != nil
  
  places = []
  
  if "all".eql?(classifier)
    places = Place.where(:updated_at.gt => search_date).sort(:updated_at.desc).all
  else
    places = Place.where(:type => classifier, :updated_at.gt => search_date).sort(:updated_at.desc).all
  end
  doc = {:time => Time.now.to_i, :count => places.count,:data => places}
  if ("json".eql?(params[:format]))
    content_type "application/json"
    doc.to_json
  else
    "ERROR"
  end
end

get '/meta/:name.:format' do
  meta_obj = Meta.where(:name => params[:name]).first
  
  doc = {:time => Time.now.to_i, :data => meta_obj}
  if ("json".eql?(params[:format]))
    content_type "application/json"
    doc.to_json
  else
    "ERROR"
  end
end