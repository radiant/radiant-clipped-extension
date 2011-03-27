class AddDefaultContentTypes < ActiveRecord::Migration

  class Config < ActiveRecord::Base; end

  def self.up
    if defined? SettingsExtension && Radiant::Config.column_names.include?('description')
      puts "-- Adding Settings Extension descriptions for assets.content_types & assets.max_asset_size"

      Config.find(:all).each do |c|
       description = case c.key
         when 'assets.content_types'
           'Defines the content types of that will be allowed to be uploaded as assets.'

         when 'assets.max_asset_size'
           'The size in megabytes that will be the max size allowed to be uploaded for an asset'
         else
           c.description
       end
       c.update_attribute :description, description
      end
    end
  end

  def self.down
  end
end
