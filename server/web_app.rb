require 'thin'
require "sinatra"

load "#{File.dirname(__FILE__)}/init.rb"

before do
  @css_files = []
  @js_files = []
end

get '/stub/:tag.:format' do
  classifier = params[:tag]
  
  search_date = 2.weeks.ago.in_time_zone
  search_date = Time.at(params[:since].to_i).in_time_zone if params[:since] != nil
  
  stubs = []
  
  if "all".eql?(classifier)
    stubs = Stub.where(:updated_at.gt => search_date).sort(:created_at.desc).all
  else
    stubs = Stub.where(:classifiers => classifier, :updated_at.gt => search_date).sort(:created_at.desc).all
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

get '/index.html' do
  @css_files << "/stubs.css"
  @js_files << "http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"
  @js_files << "/js/stubs.js"
  @js_files << "/js/latest.js"
  @stubs = Stub.sort(:created_at.desc).limit(30).all
  
  erb :index
end

get '/food.html' do
  @css_files << "/stubs.css"
  @js_files << "http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"
  @js_files << "/js/stubs.js"
  @js_files << "/js/food.js"
  @stubs = Stub.where(:classifiers => "food").sort(:created_at.desc).limit(30).all
  
  erb :index
end

get '/events.html' do
  @css_files << "/stubs.css"
  @js_files << "http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"
  @js_files << "/js/stubs.js"
  @js_files << "/js/events.js"
  @stubs = Stub.where(:classifiers => "event").sort(:created_at.desc).limit(30).all
  
  erb :index
end