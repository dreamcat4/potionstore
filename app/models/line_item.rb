require 'licensekey'

class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  validates_numericality_of :quantity, :only_integer => true
  validates_numericality_of :unit_price

  attr_protected :license_key

  def quantity=(qty)
    # take care of leading zeroes so that the quantity does not get treated as an octal number
    qty = qty.to_s.strip.sub(/^0+/, '')
    qty = 0 if qty == ''
    qty = Integer(Float(qty).ceil)

    # Don't automatically generate a new key for pending orders
    regenerate_keys = (self.quantity != qty) && self.order.status != 'P'
    write_attribute(:quantity, qty)

    if regenerate_keys
      self.license_key = generate_license_key()
    end
  end

  def total
    return round_money(quantity * self.unit_price)
  end

  def vatex_unit_price
    return round_money( self.unit_price / (1 + TaxTableFactory.uk_vat_rate) )
  end

  def volume_price
    # This is hard coded for now. Modify to suit your needs
    if self.product.code == 'pcm'
      return 19.95 if quantity >= 20
      return 22.95 if quantity >= 10
      return 24.95 if quantity >= 2
    elsif self.product.code == 'vc'
      return 9.95 if self.order.has_item_with_code('tgr')
    end
    return unit_price
  end

  def regular_price
    return product.price
  end

  def generate_license_key
    return make_license(self.product.code, self.order.licensee_name, self.quantity)
  end

  def license_url
    return self.product.license_url_scheme + '://' + self.license_key rescue nil
  end

end
