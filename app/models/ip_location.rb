class IpLocation < ActiveRecord::Base

  # def initialize(loc = GeoLoc.new)

    # @lat = loc.lat
    # @lng = loc.lng
    # @ip_address = loc.ip_address
    # @isp_detail = loc.isp_detail
    # @street_address = loc.street_address
    # @city = loc.city
    # @state = loc.state
    # @zip = loc.zip
    # @country_code = loc.country_code
    # @full_address = loc.full_address
    # @success = loc.success
    # @provider = loc.provider
    # @precision = loc.precision

    # self.lat = loc.lat
    # self.lng = loc.lng
    # self.ip_address = loc.ip_address
    # self.isp_detail = loc.isp_detail
    # self.street_address = loc.street_address
    # self.city = loc.city
    # self.state = loc.state
    # self.zip = loc.zip
    # self.country_code = loc.country_code
    # self.full_address = loc.full_address
    # self.success = loc.success
    # self.provider = loc.provider
    # self.precision = loc.precision

    # lat = loc.lat
    # lng = loc.lng
    # ip_address = loc.ip_address
    # isp_detail = loc.isp_detail
    # street_address = loc.street_address
    # city = loc.city
    # state = loc.state
    # zip = loc.zip
    # country_code = loc.country_code
    # full_address = loc.full_address
    # success = loc.success
    # provider = loc.provider
    # precision = loc.precision

  # end
  
  def location=(loc)

    self.lat = loc.lat
    self.lng = loc.lng
    self.ip_address = loc.ip_address
    self.isp_detail = loc.isp_detail
    self.street_address = loc.street_address
    self.city = loc.city
    self.state = loc.state
    self.zip = loc.zip
    self.country_code = loc.country_code
    self.full_address = loc.full_address
    self.success = loc.success
    self.provider = loc.provider
    self.precision = loc.precision

  end

end
