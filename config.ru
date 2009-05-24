require File.dirname(__FILE__) + '/config/environment'
require 'thin'

app = Rack::Builder.new {
  use Rails::Rack::Static
  run Rack::Cascade.new([Sinatra::Application, ActionController::Dispatcher.new])
}.to_app

# Rack::Handler::Thin.run app, :Port => @options.port, :Host => "0.0.0.0"
# Rack::Handler::Thin.run app

# Rack::Handler::Thin.run app, :Port => 3005, :Host => "0.0.0.0"

run app
