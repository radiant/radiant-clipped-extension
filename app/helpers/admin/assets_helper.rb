module Admin::AssetsHelper
  
  def automatic_size_descriptions
    Asset.thumbnail_sizes.collect{|k,v| "#{k} (#{(v.to_s).match(/\d+x\d+/)})"}.join(', ')
  end
  
  def image_for_asset(asset)
    # TODO: Move icon to mime-type code so that extensions can extend this easily
    case 
    when asset.image?
      image "assets/image_icon"
    when asset.video?
      image "assets/video_icon"
    when asset.audio?
      image "assets/audio_icon"
    # when asset.document?
    #   image "assets/document_icon"
    else
      image "assets/unknown_icon"
    end
  end
  
end