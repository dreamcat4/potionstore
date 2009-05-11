# require 'vendor/gems/geokit'
# require 'geocoders-ext'
# require 'geokit'

# include Geokit
# include Geokit::Geocoders

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  # Auto-geocode the user's ip address and store in the session.
  geocode_ip_address
  
  def geokit
    @location = session[:geo_location]  # @location is a GeoLoc instance.
  end

  # Don't log any credit card data
  filter_parameter_logging :password, :cc_number, :cc_code, :cc_month, :cc_year

  def check_authentication
    unless session[:logged_in]
      session[:intended_url] = request.request_uri
      logger.debug('intended_url: ' + session[:intended_url])
      redirect_to :controller => "/admin", :action => "login"
    end
  end

  def redirect_to_ssl
    if is_live?() && $STORE_PREFS['redirect_to_ssl']
      redirect_to :protocol => "https://" unless (request.ssl? or local_request?)
    end
  end

end


# Convenience global function to check if we're running in production mode
def is_live?
  return ENV['RAILS_ENV'] == 'production'
  # return true
end


# Load store preferences
def load_store_prefs
  app_root = File.dirname(__FILE__) + '/../..'
  config_dir = app_root + '/config/'

  ymlpath = File.expand_path(config_dir + 'store.yml')
  $STORE_PREFS = YAML.load(File.open(ymlpath))
end

load_store_prefs()


# Convenience global function for rounding to monetary amount
def round_money(amount)
  return ("%01.2f" % amount).to_f()
end


# Setup Google Checkout if it's in use
if $STORE_PREFS['allow_google_checkout']

  require 'google4r/checkout'

  $GCHECKOUT_FRONTEND = nil

  # class TaxTableFactory
  #   def effective_tax_tables_at(time)
  # 
  #     tax_free_table = Google4R::Checkout::TaxTable.new(false)
  #     tax_free_table.name = "default table"
  #     tax_free_table.create_rule do |rule|
  #       rule.area = Google4R::Checkout::UsCountryArea.new(Google4R::Checkout::UsCountryArea::ALL)
  #       rule.rate = 0.0
  #     end
  #     return [tax_free_table]
  #   end
  # end
  class TaxTableFactory
    
    attr_reader :eu_countries
    
    def initialize()
      @eu_countries = [ 'AT', 'BE', 'BG', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', \
                        'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', \
                        'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB' ] 
    end
    
    def TaxTableFactory.eu_countries()
      return TaxTableFactory::new().eu_countries
    end
    
    def eu_countries()
      return @eu_countries
    end
    
    def TaxTableFactory.uk_vat_rate_at(time)
      return TaxTableFactory::new().uk_vat_rate_at(time)
    end
    
    def TaxTableFactory.uk_vat_rate()
      return TaxTableFactory::new().uk_vat_rate()
    end
    
    def uk_vat_rate()
      return uk_vat_rate_at(Time.new().getutc)
    end
    
    def uk_vat_rate_at(time=time.getutc)
      # if time > Time.parse("Mon Dec 01 00:00:00 UTC 2008") &&
        if time < Time.parse("Fri Jan 01 00:00:00 UTC 2010") then
          uk_vat_rate = 0.15
        else
          uk_vat_rate = 0.175
        end
        return uk_vat_rate       
    end
    
    def effective_tax_tables_at(time)
      eu_tax_table = Google4R::Checkout::TaxTable.new(false)
      eu_tax_table.name = "default table"

      for eu_country in @eu_countries 
          eu_tax_table.create_rule do |rule|
            rule.area = Google4R::Checkout::PostalArea.new(eu_country)
            rule.rate = self.uk_vat_rate_at(time)
          end
      end
      # return [eu_tax_table]
      
      # for eu_country in @eu_countries do |eu_rule|
      #   eu_rule = eu_tax_table.create_rule
      #   eu_rule.area = Google4R::Checkout::PostalArea.new(eu_country)
      #   eu_rule.rate = self.uk_vat_rate_at(time)
      # end
      
      return [eu_tax_table]
    end
  end

  def _initialize_google_checkout
    environment = ENV['RAILS_ENV'] || 'production'

    app_root = File.dirname(__FILE__) + '/../..'
    config_dir = app_root + '/config'

    prefs = File.expand_path(config_dir + '/google_checkout.yml')
    if File.exists?(prefs)
      y = YAML.load(File.open(prefs))[environment]

      # Save the merchant id and key. It gets used in notification_controller for authenticating Google's notifications
      $STORE_PREFS['gcheckout_merchant_id'] = y['gcheckout_merchant_id']
      $STORE_PREFS['gcheckout_merchant_key'] = y['gcheckout_merchant_key']
      $STORE_PREFS['gcheckout_sandbox'] = y['gcheckout_sandbox']

      $GCHECKOUT_FRONTEND = Google4R::Checkout::Frontend.new(:merchant_id => y['gcheckout_merchant_id'],
                                                             :merchant_key => y['gcheckout_merchant_key'],
                                                             :use_sandbox => !!y['gcheckout_sandbox'])

      $GCHECKOUT_FRONTEND.tax_table_factory = TaxTableFactory.new
    else
      logger.error("Could not load Google Checkout configuration even though it's enabled")
    end
  end

  # Go ahead and call the Google Checkout initialization function
  _initialize_google_checkout()

end
