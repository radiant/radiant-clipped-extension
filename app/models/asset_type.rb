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
  attr_reader :name, :processors, :styles, :icon_name, :catchall, :default_radius_tag
  
  def initialize(name, options = {})
    options = options.symbolize_keys
    @name = name
    @icon_name = options[:icon] || name
    @processors = options[:processors] || []
    @styles = options[:styles] || {}
    @mimes = options[:mime_types] || []
    @default_radius_tag = options[:default_radius_tag] || 'link'
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

  def icon(style_name='icon')
    if File.exist?("#{RAILS_ROOT}/public/images/admin/assets/#{icon_name}_#{style_name.to_s}.png")
      return "/images/admin/assets/#{icon_name}_#{style_name.to_s}.png"
    else
      return "/images/admin/assets/#{icon_name}_icon.png"
    end
  end
  
  def icon_path(style_name='icon')
    "#{RAILS_ROOT}/public#{icon(style_name)}"
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
    Radiant.config["assets.skip_#{name}_processing?"] ? [] : processors
  end
  
  def paperclip_styles
    paperclip_processors.any? ? styles.merge(configured_styles) : {}
  end
  
  def configured_styles
    Radiant::Config["assets.additional_thumbnails"].gsub(' ','').split(',').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = [v, :jpg]; ha}
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
