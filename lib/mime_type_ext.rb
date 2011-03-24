class Mime::Type

  #TODO bring across AssetType mechanism instead of this
  
  attr_reader :synonyms
  
  def all_types
    ([self.to_s] + synonyms).uniq
  end
end
