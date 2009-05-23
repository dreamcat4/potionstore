require File.dirname(__FILE__) + '/config/environment'
require 'thin'
  
app = Rack::Builder.new {
  use Rails::Rack::Static
  run Rack::Cascade.new([Sinatra.application, ActionController::Dispatcher.new])
}.to_app
 
Rack::Handler::Thin.run app, :Port => 3000, :Host => "0.0.0.0"
