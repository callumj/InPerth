require "rubygems"
require "bundler"
require 'open-uri'
Bundler.require(:default)

#load models
MongoMapper.database = 'inperth'
Dir["#{File.dirname(__FILE__)}/models/**/*.rb"].each { |f| load(f) }

#load helpers
Dir["#{File.dirname(__FILE__)}/helpers/**/*.rb"].each { |f| load(f) }