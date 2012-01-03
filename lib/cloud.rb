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

    def self.directory
      Radiant.config["paperclip.fog.directory"] ||
      Radiant.config["paperclip.s3.bucket"] ||
      Radiant.config["assets.s3.bucket"]
    end

    def self.host
      if Radiant.config["paperclip.fog.host"]
        Radiant.config["paperclip.fog.host"]
      elsif Radiant.config["paperclip.s3.host_alias"]
        "http://#{Radiant.config['paperclip.s3.host_alias']}"
      elsif Radiant.config["assets.storage"] == "s3"
        "http://#{directory}.s3.amazonaws.com"
      else
        case Radiant.config["paperclip.fog.provider"]
        when "AWS"
          "http://#{directory}.s3.amazonaws.com"
        else
          nil
        end
      end
    end

    def self.storage
      if Radiant.config["assets.storage"] == "s3"
        :fog
      elsif Radiant.config["paperclip.storage"]
        case Radiant.config["paperclip.storage"]
        when "fog"
          :fog
        when "s3"
          :fog
        else
          :filesystem
        end
      end
    end

  end

end
