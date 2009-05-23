class Qbwc::ApiController < ApplicationController
  get '/qbwc/api' do
    # return "Home page - qbwc api"
    return "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
  end

  get '/qbwc/api/request' do
    return "xml response"
  end

  def new
  end

end

# class SiteController < ApplicationController
#   get '/:name' do
#     Site.find_by_name(params[:name]).html
#   end
#   def new
#   end
# end
# 
# class HomeController < ApplicationController
#   get '/' do
#     Item.count.to_s
#   end
#   def index
#   end
# end
# 
# require 'sinatra/base' 
# class Articles < Sinatra::Base 
#   post '/articles' do 
#     article = Article.create! params 
#     redirect "/articles/#{article.id}" 
#   end 
#   get '/articles/:id' do 
#     @article = Article.find(params[:id]) 
#     erb :article 
#   end 
# end 
# 
