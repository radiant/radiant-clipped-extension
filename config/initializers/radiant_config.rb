Radiant.config do |config|
  config.namespace 'assets', :allow_display => false, :allow_change => false do |assets|
    
    # these are structural and can't be changed through the admin interface

    assets.define 'additional_thumbnails',    :default => 'normal=640x640>'
    assets.define 'url',                      :default => '/:class/:id/:basename:no_original_style.:extension'
    assets.define 'path',                     :default => ':rails_root/public/:class/:id/:basename:no_original_style.:extension'
    assets.define 'skip_filetype_validation', :default => true, :type => :boolean
    assets.define 'storage', :default     => 'filesystem',
                             :select_from => {'File System' => 'filesystem', 'Amazon S3' => 's3'},
                             :allow_blank => false

    assets.namespace 's3' do |s3|
      s3.define 'bucket'
      s3.define 'key'
      s3.define 'secret'
      s3.define 'host_alias'
    end

    # this is reconfigurable
    assets.define 'max_asset_size', :default => 5, :type => :integer, :units => 'MB', :allow_change => true
    
    # these too. I'd like to add a selection definition but it causes all sorts of load-order trouble with the declaration of asset types
    assets.define 'display_size', :default => 'normal', :allow_change => true, :allow_blank => true
    assets.define 'insertion_size', :default => 'normal', :allow_change => true, :allow_blank => true
  end
  
end

