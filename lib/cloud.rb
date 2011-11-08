module RadiantClippedExtension

  module Cloud

    def self.credentials
      case Radiant.config["paperclip.fog.provider"]
      when "AWS"
        return {
          :provider => "AWS",
          :aws_access_key_id => Radiant.config["paperclip.s3.key"],
          :aws_secret_access_key => Radiant.config["paperclip.s3.secret"],
          :region => Radiant.config["paperclip.s3.region"],
        }
      when "Google"
        return {
          :provider => "Google",
          :rackspace_username => Radiant.config["paperclip.google_storage.access_key_id"],
          :rackspace_api_key  => Radiant.config["paperclip.google_storage.secret_access_key"]
        }
      when "Rackspace"
        return {
          :provider => "Rackspace",
          :rackspace_username => Radiant.config["paperclip.rackspace.username"],
          :rackspace_api_key  => Radiant.config["paperclip.rackspace.api_key"]
        }
      end
    end

    def self.storage
      if Radiant.config["paperclip.storage"] == "s3"
        :fog
      else
        Radiant.config["paperclip.storage"]
      end
    end

  end

end
