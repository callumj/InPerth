require "rubygems"
require "bundler"
require 'open-uri'
Bundler.require(:default)

#load models
#MongoMapper.connection = Mongo::Connection.new('mullac.org', '37017')
MongoMapper.database = 'inperth'
Dir["#{File.dirname(__FILE__)}/models/**/*.rb"].each { |f| load(f) }

#load helpers
Dir["#{File.dirname(__FILE__)}/helpers/**/*.rb"].each { |f| load(f) }

#load libs
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| load(f) }

#load pipelines
Dir["#{File.dirname(__FILE__)}/pipelines/**/*.rb"].each { |f| load(f) }

#set timezone
Time.zone = "Perth"