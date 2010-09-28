module Admin::AssetsHelper
  def automatic_size_descriptions
    Asset.thumbnail_sizes.collect{|k,v| "#{k} (#{(v.to_s).match(/\d+x\d+/)})"}.join(', ')
  end
end