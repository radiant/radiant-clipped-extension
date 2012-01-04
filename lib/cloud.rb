module RadiantClippedExtension

  module Cloud

    def self.credentials
      case Radiant.config["paperclip.fog.provider"]
      when "AWS"
        {
          :provider => "AWS",
          :aws_access_key_id => Radiant.config["paperclip.s3.key"],
          :aws_secret_access_key => Radiant.config["paperclip.s3.secret"],
          :region => Radiant.config["paperclip.s3.region"],
        }
      when "Google"
        {
          :provider => "Google",
          :rackspace_username => Radiant.config["paperclip.google_storage.access_key_id"],
          :rackspace_api_key  => Radiant.config["paperclip.google_storage.secret_access_key"]
        }
      when "Rackspace"
        {
          :provider => "Rackspace",
          :rackspace_username => Radiant.config["paperclip.rackspace.username"],
          :rackspace_api_key  => Radiant.config["paperclip.rackspace.api_key"]
        }
      end
    end

    def self.host
      return Radiant.config["paperclip.fog.host"] if Radiant.config["paperclip.fog.host"]
      case Radiant.config["paperclip.fog.provider"]
      when "AWS"
        "http://#{Radiant.config['paperclip.fog.directory']}.s3.amazonaws.com"
      else
        nil
      end
    end

  end

end
