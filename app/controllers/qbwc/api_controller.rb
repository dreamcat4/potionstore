# require 'rubygems'
# require 'sinatra'
require 'hpricot'
require 'fast_xs' # http server - "fast escaping" ?

set :views, "#{RAILS_ROOT}" + '/app/views/sinatra/qbwc'

class NilClass
  def fast_xs
    ''
  end
end

class Qbwc::ApiController < ApplicationController
  layout "admin"

  before_filter :redirect_to_ssl

  get '/qbwc/lorem' do
    # return "Home page - qbwc api"
    return "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
  end

  get '/qbwc/api/error' do
    @message = 'An error occurred'
    puts "#{erb :getLastError}"
    erb :getLastError
  end

  # get '/qbwc/orders/:query' do
  get '/qbwc/orders' do
    # @message = 'Orders'
    
    test_string = String.new()
    test_string = "Hi! i am a string of artritrary length and size :)"
    html = "#{test_string}<br>bytesize=#{test_string.bytesize}"
    return html
    
    q = params[:query]
    conditions = "(status='C' OR status='X' OR status='F')"
    if q
      q = q.strip().downcase()
      if q.to_i != 0
        conditions = [conditions + "AND id=?", q.to_i]
        # @order = Order.find(q)
        # puts @order.to_xml
        # @message = @order.to_xml
        # return
      else
        conditions = [conditions + " AND (LOWER(email) LIKE ? OR
                                          LOWER(first_name) LIKE ? OR
                                          LOWER(last_name) LIKE ? OR
                                          LOWER(licensee_name) LIKE ?)", "#{q}%", "#{q}%", "#{q}%", "%#{q}%"]
      end
    end
    # @orders = Order.paginate :page => (params[:page] || 1), :per_page => 100, :conditions => conditions, :order => 'order_time DESC'
    @orders = Order.paginate :page => 1

  end

  get '/qbwc/hello/:name' do
    # matches "GET /hello/foo" and "GET /hello/bar"
    # params[:name] is 'foo' or 'bar'
    "Hello #{params[:name]}!"
  end
  
  # GET /orders/1
  # GET /orders/1.xml
  get '/qbwc/order/:id' do
    @order = Order.find(params[:id])
    puts @order.to_xml
    # @message = @order

    # respond_to do |format|
    #   format.html # show.rhtml
    #   format.xml  { render :xml => @order.to_xml }
    # end
    @message = @order.to_xml
    
  end
  
  # def new
  # end

  post '/qbwc/api' do
    content_type 'text/xml'

    payload = Hpricot.uxs(request.body.read)
    doc = Hpricot.XML(payload)
    api_call = doc.containers[0].containers[0].containers[0].name.split(':').last

    # log request
    puts ''
    puts "========== #{api_call}  =========="
    puts payload

    case api_call
    when 'serverVersion'
      erb :serverVersion
    when 'clientVersion'
      erb :clientVersion
    when 'authenticate'
      @token = 'abc123'
      erb :authenticate
    when 'sendRequestXML'
      @qbxml = <<-XML
  <?xml version="1.0" ?>
  <?qbxml version="5.0" ?>
  <QBXML>
    <QBXMLMsgsRq onError="continueOnError">
      <CustomerQueryRq requestID="1">
        <MaxReturned>10</MaxReturned>
        <IncludeRetElement>Name</IncludeRetElement>
      </CustomerQueryRq>
    </QBXMLMsgsRq>
  </QBXML>
  XML
      erb :sendRequestXML
    when 'receiveResponseXML'
      (doc/'CustomerRet').each do |node|
        puts "Customer: #{node.innerText.strip}"
      end
      @result = 100
      erb :receiveResponseXML
    when 'getLastError'
      @message = 'An error occurred'
      erb :getLastError
    when 'connectionError'
      @message = 'done'
      erb :connectionError
    when 'closeConnection'
      @message = 'OK'
      erb :closeConnection
    else
      ''
    end
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
