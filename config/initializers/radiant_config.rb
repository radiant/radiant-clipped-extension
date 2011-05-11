Radiant.config do |config|
  config.namespace 'assets', :allow_display => false do |assets|
    assets.define 'display_size',             :default => 'normal'
    assets.define 'additional_thumbnails',    :default => 'normal=640x640>'
    assets.define 'url',                      :default => '/:class/:id/:basename:no_original_style.:extension'
    assets.define 'path',                     :default => ':rails_root/public/:class/:id/:basename:no_original_style.:extension'
    assets.define 'content_types',            :default => 'image/jpeg, image/pjpeg, image/gif, image/png, image/x-png, image/jpg, video/x-m4v, video/quicktime, application/x-shockwave-flash, audio/mpeg, video/mpeg'
    assets.define 'skip_filetype_validation', :default => true, :type => :boolean
    assets.define 'max_asset_size',           :default => 5,    :type => :integer

    assets.define 'storage', :default     => 'filesystem',
                             :select_from => {'File System' => 'filesystem', 'Amazon S3' => 's3'},
                             :allow_blank => false

    assets.namespace 's3' do |s3|
      s3.define 'bucket'
      s3.define 'host_alias'
      s3.define 'key'
      s3.define 'secret'
    end
  end
end
