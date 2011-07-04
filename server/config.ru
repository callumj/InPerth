require File.dirname(__FILE__) + "/web_app.rb"


set :env, :production
set :server, 'thin'
disable :run

run Sinatra::Application