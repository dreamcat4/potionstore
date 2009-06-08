require ::File.dirname(__FILE__) + '/config/environment'
require 'thin'

app = Rack::Builder.new {
  use Rack::CommonLogger
  use Rails::Rack::Static
  run Rack::Cascade.new([Sinatra::Application, ActionController::Dispatcher.new])
}.to_app

run app
