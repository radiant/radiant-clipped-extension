module Admin::AssetsHelper
  
  def automatic_size_descriptions
    Asset.thumbnail_sizes.collect{|k,v| "#{k} (#{(v.to_s).match(/\d+x\d+/)})"}.join(', ')
  end
  
  def asset_insertion_link(asset)
    link_to t('assets_extension.insert'), '#', :class => 'insert_asset', :rel => asset.insertion_rel
  end
  
end