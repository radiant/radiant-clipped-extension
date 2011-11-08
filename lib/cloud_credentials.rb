module RadiantClippedExtension

  def self.cloud_credentials
    case Radiant.config["paperclip.fog.provider"]
    when "AWS"
      return {
        :provider => "AWS",
        :aws_access_key_id => Radiant.config["paperclip.s3.key"],
        :aws_secret_access_key => Radiant.config["paperclip.s3.secret"],
        :region => Radiant.config["paperclip.s3.region"],
      }
    when "Rackspace"
      return {
        :provider => "Rackspace",
        :rackspace_username => Radiant.config["paperclip.rackspace.username"],
        :rackspace_api_key  => Radiant.config["paperclip.rackspace.api_key"]
      }
    end
  end

end
