
class AddGeokit < ActiveRecord::Migration

  def self.up
    
    create_table :ip_locations do |t| 

      t.float :lat
      t.float :lng
      t.string :ip_address
      t.string :isp_detail
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country_code
      t.string :full_address
      t.boolean :success
      t.string :provider
      t.string :precision  
      t.integer :order_id 
      # t.timestamps

    end 

    # add_column :orders, :ip_location_id, :integer

    # add_index :orders, :ip_location_id 
    # add_index :orders, :ip_location_id, :name => "ip_location_id"

  end

  def self.down
    
    # remove_column :orders, :ip_location_id
    drop_table :ip_locations
    
  end
  
end
