class UpdateConfiguration < ActiveRecord::Migration
  def self.up
    if Radiant.config.table_exists?

      puts "Importing paperclip configuration"
      %w{url path skip_filetype_validation storage}.select{|k| !!Radiant.config["assets.#{k}"] }.each do |k|
        begin
          Radiant.config["paperclip.#{k}"] = Radiant.config["assets.#{k}"]
        rescue ActiveRecord::RecordInvalid => e
          print "Oops! There was trouble setting #{k} to '#{Radiant.config["assets.#{k}"]}'"
          print "\nSetting it to 'fog'. Please see the clipped extension README for more details."
          Radiant.config["paperclip.#{k}"] = 'fog'
        end
      end

      puts "Importing s3 storage configuration"
      %w{bucket key secret host_alias}.select{|k| !!Radiant.config["assets.s3.#{k}"] }.each do |k|
        Radiant.config["paperclip.s3.#{k}"] = Radiant.config["assets.s3.#{k}"]
      end

      puts "Importing thumbnail configuration"
      if thumbnails = Radiant.config["assets.additional_thumbnails"]
        old_styles = thumbnails.to_s.gsub(' ','').split(',').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
        new_styles = old_styles.map {|k,v| "#{k}:size=#{v}"}
        Radiant.config["assets.thumbnails.image"] = new_styles.join("|")
        Radiant.config["assets.thumbnails.video"] = new_styles.map{|s| "#{s},format=jpg"}.join("|")
        Radiant.config["assets.thumbnails.pdf"] = new_styles.map{|s| "#{s},format=jpg"}.join("|")
      end
    end
  end

  def self.down
  end
end
