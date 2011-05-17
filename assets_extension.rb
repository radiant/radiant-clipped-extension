require_dependency 'application_controller'

class AssetsExtension < Radiant::Extension
  version "1.0.0.rc1"
  description "Assets extension based Keith Bingman's original Paperclipped extension."
  url "http://github.com/radiant/radiant-assets-extension"

  extension_config do |config|
    config.gem "uuidtools"
    config.gem 'paperclip', :version => '~> 2.3.3'
    config.gem 'acts_as_list'
  end
  
  def activate
    if Asset.table_exists?
      Page.send :include, PageAssetAssociations                                          # defines page-asset associations. likely to be generalised soon.
      Radiant::AdminUI.send :include, AssetsAdminUI unless defined? admin.asset          # defines shards for extension of the asset-admin interface
      Admin::PagesController.send :helper, Admin::AssetsHelper                           # currently only provides a description of asset sizes
      Page.send :include, AssetTags                                                      # radius tags for selecting sets of assets and presenting each one
      UserActionObserver.instance.send :add_observer!, Asset                             # the usual creator- and updater-stamping
    
      AssetType.new :image, :icons => {:icon => "/images/admin/assets/image_icon.png", :default => "/images/admin/assets/image_thumbnail.png"}, :mime_types => %w[image/png image/x-png image/jpeg image/pjpeg image/jpg image/gif], :processors => [:thumbnail], :styles => {:icon => ['42x42#', :png], :thumbnail => ['100x100>', :png]}
      AssetType.new :video, :icons => {:icon => "/images/admin/assets/video_icon.png", :default => "/images/admin/assets/video_thumbnail.png"}, :mime_types => %w[video/mpeg video/mp4 video/ogg video/quicktime video/x-ms-wmv video/x-flv]
      AssetType.new :audio, :icons => {:icon => "/images/admin/assets/audio_icon.png", :default => "/images/admin/assets/audio_thumbnail.png"}, :mime_types => %w[audio/mpeg audio/mpg audio/ogg application/ogg audio/x-ms-wma audio/vnd.rn-realaudio audio/x-wav]
      AssetType.new :document, :icons => {:icon => "/images/admin/assets/document_icon.png", :default => "/images/admin/assets/document_thumbnail.png"}, :mime_types => %w[application/msword application/pdf application/rtf application/vnd.ms-excel application/vnd.ms-powerpoint application/vnd.ms-project application/vnd.ms-works text/plain text/html]
      AssetType.new :other, :icons => {:icon => "/images/admin/assets/unknown_icon.png", :default => "/images/admin/assets/unknown_thumbnail.png"}

      # more asset types will follow to use the new icon set
    
      admin.asset ||= Radiant::AdminUI.load_default_asset_regions                        # loads the shards defined in AssetsAdminUI
      admin.page.edit.add :form, 'assets', :after => :edit_page_parts                    # adds the asset-attachment picker to the page edit view
      admin.page.edit.add :main, 'asset_popups', :after => :edit_popups                  # adds the asset-attachment picker to the page edit view
      admin.page.edit.asset_popups.concat %w{upload_asset attach_asset}
      admin.page.edit.thead.concat %w{thumbnail_header content_type_header actions_header}              # duplicates asset-index partials
      admin.page.edit.tbody.concat %w{thumbnail_cell title_cell content_type_cell actions_cell}         # so that we can use the same asset table as a picker when editing pages
      admin.configuration.show.add :config, 'admin/configuration/show', :after => 'defaults'
      admin.configuration.edit.add :form,   'admin/configuration/edit', :after => 'edit_defaults'
    
      if Radiant::Config.table_exists? && Radiant::Config["assets.image_magick_path"]    # This is just needed for testing if you are using mod_rails
        Paperclip.options[:image_magick_path] = Radiant::Config["assets.image_magick_path"]
      end
    
      tab "Assets", :after => "Content" do
        add_item "All", "/admin/assets/"
      end
    
      if RAILS_ENV == 'development'
        update_sass_each_request
        update_javascript_each_request
      end
    end
  end
  
  def deactivate
    
  end
  
  private
  
    def update_sass_each_request
      ApplicationController.class_eval do
        prepend_before_filter :update_assets_sass
        def update_assets_sass
          radiant_assets_sass = "#{RAILS_ROOT}/public/stylesheets/sass/admin/assets.sass"
          extension_assets_sass = "#{AssetsExtension.root}/public/stylesheets/sass/admin/assets.sass"
          FileUtils.mkpath File.dirname(radiant_assets_sass)
          if (not File.exists?(radiant_assets_sass)) or (File.mtime(extension_assets_sass) > File.mtime(radiant_assets_sass))
            FileUtils.cp extension_assets_sass, radiant_assets_sass
          end
        end
      end
    end
    
    def update_javascript_each_request
      ApplicationController.class_eval do
        prepend_before_filter :update_assets_javascript
        def update_assets_javascript
          radiant_assets_javascript = "#{RAILS_ROOT}/public/javascripts/admin/assets.js"
          extension_assets_javascript = "#{AssetsExtension.root}/public/javascripts/admin/assets.js"
          FileUtils.mkpath File.dirname(radiant_assets_javascript)
          if (not File.exists?(radiant_assets_javascript)) or (File.mtime(extension_assets_javascript) > File.mtime(radiant_assets_javascript))
            FileUtils.cp extension_assets_javascript, radiant_assets_javascript
          end
        end
      end
    end
  
end
