class AssetType
  
  # The Asset Type encapsulates a type of attachment.
  # Conventionally this would a sensible category like 'image' or 'video'
  # that should be processed and presented in a particular way.
  # An AssetType currently provides:
  #   * processor definitions for paperclip
  #   * styles definitions for paperclip
  #   * mime type list for file recognition
  #   * selectors and scopes for retrieving this (or not this) category of asset
  #   * radius tags for those subsets of assets (temporarily removed pending discussion of interface)
  
  @@types = []
  @@type_lookup = {}
  @@mime_lookup = {}
  @@default_type = nil
  attr_reader :name, :processors, :styles, :icons, :catchall
  
  def initialize(name, options = {})
    options = options.symbolize_keys
    @name = name
    @processors = options[:processors]
    @styles = options[:styles] || {}
    @mimes = options[:mime_types] || []
    if options[:icons]
      @icons = options[:icons].symbolize_keys
    elsif options[:icon]
      @icons = {:all => options[:icon]}
    else
      @icons = {}
    end
    if @mimes.any?
      @mimes.each { |mimetype| @@mime_lookup[mimetype] ||= self }
    end
    this = self
    Asset.send :define_method, "#{name}?".intern do this.mime_types.include?(asset_content_type) end 
    Asset.send :define_class_method, "#{name}_condition".intern do this.condition; end
    Asset.send :define_class_method, "not_#{name}_condition".intern do this.non_condition; end
    Asset.send :named_scope, plural.to_sym, :conditions => condition
    Asset.send :named_scope, "not_#{plural}".to_sym, :conditions => non_condition
    
    # Page.define_radius_tags_for_asset_type self     #TODO discuss interface
    @@types.push self
    @@type_lookup[@name] = self
  end
  
  def plural
    name.to_s.pluralize
  end

  def icon(style_name=:icon)
    return icons[:all] || icons[style_name.to_sym] || icons[:default]
  end

  def condition
    if @mimes.any?
      ["asset_content_type IN (#{@mimes.map{'?'}.join(',')})", *@mimes]
    else
      self.class.other_condition
    end
  end
  
  def sanitized_condition
    ActiveRecord::Base.send :sanitize_sql_array, condition
  end

  def non_condition
    if @mimes.any?
      ["NOT asset_content_type IN (#{@mimes.map{'?'}.join(',')})", *@mimes]
    else
      self.class.non_other_condition
    end
  end

  def sanitized_non_condition
    ActiveRecord::Base.send :sanitize_sql_array, non_condition
  end

  def mime_types
    @mimes
  end

  def paperclip_processors
    processors || []
  end
  
  def paperclip_styles
    styles.merge(name == :image ? image_styles : other_configured_styles)
  end

  def image_styles
    required_thumbnails = {
      :icon => ['42x42#', :png],
      :thumbnail => ['100x100>', :png],
      :sample => ['100x100#', :png]
    }
    Radiant::Config["assets.additional_thumbnails"].gsub(' ','').split(',').collect{|s| s.split('=')}.inject(required_thumbnails) {|ha, (k, v)| ha[k.to_sym] = v; ha}
  end

  def other_configured_styles
    styles = []
    styles = Radiant::Config["assets.additional_#{name}_thumbnails"].gsub(/\s+/,'').split(',') if Radiant::Config["assets.additional_#{name}_thumbnails"]
    styles.collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
  end

  def style_dimensions(style_name)
    if style = paperclip_styles[style_name.to_sym]
      style.is_a?(Array) ? style.first : style
    end
  end
  
  def style_format(style_name)
    if style = paperclip_styles[style_name.to_sym]
      style.last if style.is_a?(Array)
    end
  end

  # class methods
  
  def self.from(mimetype)
    @@mime_lookup[mimetype] || catchall
  end
  
  def self.catchall
    @@default_type ||= self.find(:other)
  end
  
  def self.known?(name)
    !self.find(name).nil?
  end

  def self.slice(*types)
    @@type_lookup.slice(*types.map(&:to_sym)).values if types
  end

  def self.find(type)
    @@type_lookup[type] if type
  end
  
  def self.all
    @@types
  end

  def self.known_types
    @@types.map(&:name) # to preserve order
  end

  def self.known_mimetypes
    @@mime_lookup.keys
  end
    
  def self.mime_types_for(*names)
    names.collect{ |name| find(name).mime_types }.flatten
  end

  def self.conditions_for(names)
    names.collect{ |name| self.find(name).sanitized_condition }.join(' OR ')
  end

  def self.non_other_condition
    ["asset_content_type IN (#{known_mimetypes.map{'?'}.join(',')})", *known_mimetypes]
  end

  def self.other_condition
    ["NOT asset_content_type IN (#{known_mimetypes.map{'?'}.join(',')})", *known_mimetypes]
  end

end

