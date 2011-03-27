class Asset < ActiveRecord::Base

  has_many :page_attachments, :dependent => :destroy
  has_many :pages, :through => :page_attachments
  has_site if respond_to? :has_site

  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  has_attached_file :asset,
                    :styles => lambda { |attachment|
                      AssetType.from(attachment.instance_read(:content_type)).paperclip_styles
                    },
                    :processors => lambda { |asset|
                      asset.paperclip_processors
                    },
                    :whiny => false,
                    :storage => Radiant.config["assets.storage"] == "s3" ? :s3 : :filesystem,
                    :s3_credentials => {
                      :access_key_id     => Radiant.config["assets.s3.key"],
                      :secret_access_key => Radiant.config["assets.s3.secret"]
                    },
                    :bucket => Radiant.config["assets.s3.bucket"],
                    :url => Radiant.config["assets.url"],
                    :path => Radiant.config["assets.path"]

  before_save :assign_title
  before_update :clear_dimensions

  validates_attachment_presence :asset, :message => "You must choose a file to upload!"
  validates_attachment_content_type :asset,
    :content_type => Radiant.config["assets.content_types"].gsub(' ','').split(',') if Radiant.config["assets.skip_filetype_validation"] == "true"
  validates_attachment_size :asset,
    :less_than => Radiant.config["assets.max_asset_size"].to_i.megabytes

  def asset_type
    AssetType.from(asset.content_type)
  end
  delegate :paperclip_processors, :paperclip_styles, :style_dimensions, :style_format, :to => :asset_type

  def thumbnail(style_name='original')
    return asset.url if style_name.to_sym == :original
    return asset.url(style_name.to_sym) if has_style?(style_name)
    return "/images/assets/#{asset_type.name}_#{style_name.to_s}.png"
  end

  def has_style?(style_name)
    paperclip_styles.keys.include?(style_name.to_sym)
  end

  def basename
    File.basename(asset_file_name, ".*") if asset_file_name
  end

  def extension
    asset_file_name.split('.').last.downcase if asset_file_name
  end

  # geometry  methods will return here
  # if they can be made more S3-friendly

private

  def assign_title
    self.title = basename if title.blank?
  end
  
  class << self
    def known_types
      AssetType.known_types
    end

    # pagination moved to the controller

    def search(search, filter)
      unless search.blank?
        search_cond_sql = []
        search_cond_sql << 'LOWER(asset_file_name) LIKE (:term)'
        search_cond_sql << 'LOWER(title) LIKE (:term)'
        search_cond_sql << 'LOWER(caption) LIKE (:term)'
        cond_sql = search_cond_sql.join(" OR ")

        @conditions = [cond_sql, {:term => "%#{search.downcase}%" }]
      else
        @conditions = []
      end

      assets = Asset.scoped( :conditions => @conditions, :order => 'created_at DESC' )
      assets = assets.scoped( :conditions => AssetType.conditions_for(filter.keys) ) unless filter.blank?
      assets
    end

    def find_all_by_asset_types(asset_types, *args)
      with_asset_types(asset_types) { find *args }
    end

    def count_with_asset_types(asset_types, *args)
      with_asset_types(asset_types) { count *args }
    end

    def with_asset_types(asset_types, &block)
      with_scope(:find => { :conditions => AssetType.conditions_for(asset_types) }, &block)
    end
  end

  # called from AssetType to set type_condition? methods on Asset
  def self.define_class_method(name, &block)
    eigenclass.send :define_method, name, &block
  end

  # returns the return value of class << self block, which is self (as defined within that block)
  def self.eigenclass
    class << self; self; end
  end

  # for backwards compatibility
  def self.thumbnail_sizes
    AssetType.find(:image).paperclip_styles
  end

  def self.thumbnail_names
    thumbnail_sizes.keys
  end

  # this is a convenience for image-pickers
  def self.thumbnail_options
    asset_sizes = thumbnail_sizes.collect{|k,v| 
      size_id = k
      size_description = "#{k}: "
      size_description << (v.is_a?(Array) ? v.join(' as ') : v)
      [size_description, size_id] 
    }.sort_by{|pair| pair.last.to_s}
    asset_sizes.unshift ['Original (as uploaded)', 'original']
    asset_sizes
  end

end
