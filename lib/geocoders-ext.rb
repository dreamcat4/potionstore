require 'geokit'

module Geokit
  module Geocoders
    @@maxmind_city = 'REPLACE_WITH_YOUR_MAXMIND_KEY'
    __define_accessors

    # Provides geocoding based upon an IP address.  The underlying web service is maxmind.com
    # MaxMind City is a paid-for service, provides country, region, and city. Updated every month.
    class MaxmindCityGeocoder < Geocoder 
      
      private 
                
      # Given an IP address, returns a GeoLoc instance which contains latitude,
      # longitude, city, and country code.  Sets the success attribute to false if the ip 
      # parameter does not match an ip address.  
      def self.do_geocode(ip)
        return Geoloc.new if '0.0.0.0' == ip
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        url = "http://geoip1.maxmind.com/f?l=#{Geokit::Geocoders::maxmind_city}&i=#{ip}"
        response = self.call_geocoder_service(url)
        response.is_a?(Net::HTTPSuccess) ? parse_csv(response.body,ip) : GeoLoc.new
      rescue
        logger.error "Caught an error during Maxmind geocoding call: "+$!
        return GeoLoc.new
      end

      # Converts the body from CSV. Fields returned:
      # 'country', 'region', 'city', 'postal', 'lat', 'lon', 'metro_code', 'area_code', 'isp', 'org', 'err'
      # then instantiates a GeoLoc instance to populate with the applicable location data.
      def self.parse_csv(body, ip) # :nodoc:
        
        if body.empty?
          return nil
        end
        
        results = body.split(",")
        
        csv_column = {'country' => 0, 'region' => 1, 'city' => 2, 'postal' => 3, 'lat' => 4, 'lon' => 5, 
                       'metro_code' => 6, 'area_code' => 7, 'isp' => 8, 'org' => 9, 'err' => 10 }
        
        res = GeoLoc.new
        res.ip_address = ip
        res.provider = 'maxmind_city'
        
        res.lat = results[ csv_column['lat'] ]
        res.lng = results[ csv_column['lon'] ]
        
        res.country_code = results[ csv_column['country'] ]
        
        postal = results[ csv_column['postal'] ]
        if !postal.empty?
          res.zip = postal
        end
        
        # Have requested that MaxMind decode the if an optional get parameter "&rd=true"
        # is specified. Until then either set drop_region_codes = true or decode them here
        # http://www.maxmind.com/app/fips_include
        drop_region_codes = false
        region = results[ csv_column['region'] ]
        if !region.empty? && !drop_region_codes 
          res.state = region
        end

        res.city = results[ csv_column['city'] ]
        
        # These two are of limited use
        # res.metro_code = results[ csv_column['metro_code'] ] # US metropolitan area
        # res.area_code = results[ csv_column['area_code'] ] # US telephone code
        
        isp = results[ csv_column['isp'] ]
        if isp =~ /\A".*"\z/m then isp.gsub!(/\A"(.*)"\z/m, '\1') end  # remove double-quotes at string beginning & end
        res.street_address = results[ csv_column['isp'] ]
        
        # Handle isp+org fields gracefully when org != isp eg org="Broadband Max 100"
        # Usually isp field should be used location purposes, org is supplementary
        org = results[ csv_column['org'] ]
        if org =~ /\A".*"\z/m then org.gsub!(/\A"(.*)"\z/m, '\1') end  # remove double-quotes at string beginning & end

        if ( org.sub(isp,"").eql? org ) && ( isp.sub(org,"").eql? isp ) 
          res.isp_detail = org
        end
        
        # MaxMind-Specific Error (eg "invalid license key")
        # For service error codes see http://www.maxmind.com/app/web_services_codes
        # res.success = !results[ csv_column['err'] ]  
        res.success = !res.country_code.empty?
        # res.success = false
        return res
      end
    end
  end
end
