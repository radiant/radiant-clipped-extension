class DisableFileTypes < ActiveRecord::Migration
  def self.up
    if defined? SettingsExtension && Radiant::Config.column_names.include?('description')
      puts "-- Adding Settings Extension descriptions for assets.skip_filetype_validations"

      Radiant::Config.find(:all).each do |c|
       description = case c.key
         when 'assets.skip_filetype_validations'
           'When set to true, disables the filetype validations. Set to false to enable them.'
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
