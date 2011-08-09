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
  @@extension_lookup = {}
  @@mime_lookup = {}
  @@default_type = nil
  attr_reader :name, :processors, :styles, :icon_name, :catchall, :default_radius_tag
  
  def initialize(name, options = {})
    options = options.symbolize_keys
    @name = name
    @icon_name = options[:icon] || name
    @processors = options[:processors] || []
    @styles = options[:styles] || {}
    @default_radius_tag = options[:default_radius_tag] || 'link'
    @extensions = options[:extensions] || []
    @extensions.each { |ext| @@extension_lookup[ext] ||= self }
    @mimes = options[:mime_types] || []
    @mimes.each { |mimetype| @@mime_lookup[mimetype] ||= self }

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
    Radiant.config["assets.create_#{name}_thumbnails?"] ? processors : []
  end
  
  def paperclip_styles
    if paperclip_processors.any?
      #TODO: define permitted options for each asset type and pass through that subset of the style-definition hash
      @paperclip_styles ||= styles.reverse_merge(configured_styles.inject({}) {|h, (k, v)| h[k] =  v[:format].blank? ? v[:size] : [v[:size], v[:format].to_sym]; h})
    else
      {}
    end
  end
  
  def configured_styles
    styles = {}
    if style_definitions = Radiant.config["assets.thumbnails.#{name}"]
      style_definitions.to_s.gsub(' ','').split('|').each do |definition|
        name, rule = definition.split(':')
        styles[name.to_sym] = rule.split(',').collect{|option| option.split('=')}.inject({}) {|h, (k, v)| h[k.to_sym] = v; h}
      end
    end
    styles
  end
  
  def legacy_styles
    Radiant::config["assets.additional_thumbnails"].to_s.gsub(' ','').split(',').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
  end
  
  def style_dimensions(style_name)
    if style = paperclip_styles[style_name.to_sym]
      style.is_a?(Array) ? style.first : style
    end
  end
  
  # class methods
  
  def self.for(attachment)
    extension = File.extname(attachment.original_filename).sub(/^\.+/, "")
    from_extension(extension) || from_mimetype(attachment.instance_read(:content_type)) || catchall
  end

  def self.from_extension(extension)
    @@extension_lookup[extension]
  end

  def self.from_mimetype(mimetype)
    @@mime_lookup[mimetype]
  end
  
  def self.catchall
    @@default_type ||= self.find(:other)
  end
  
  def self.known?(name)
    !self.find(name).nil?
  end

  def self.slice(*types)
    @@type_lookup.slice(*types.map(&:to_sym)).values if types   # Hash#slice is provided by will_paginate
  end

  def self.find(type)
    @@type_lookup[type] if type
  end
  def self.[](type)
    find(type)
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

  def self.conditions_for(*names)
    names.collect{ |name| self.find(name).sanitized_condition }.join(' OR ')
  end

  def self.non_other_condition
    ["asset_content_type IN (#{known_mimetypes.map{'?'}.join(',')})", *known_mimetypes]
  end

  def self.other_condition
    ["NOT asset_content_type IN (#{known_mimetypes.map{'?'}.join(',')})", *known_mimetypes]
  end

end
