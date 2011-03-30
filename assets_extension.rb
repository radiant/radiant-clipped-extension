require_dependency 'application_controller'
require File.dirname(__FILE__) + '/lib/url_additions'
include UrlAdditions

class AssetsExtension < Radiant::Extension
  version "1.0"
  description "Assets extension based Keith Bingman's original Paperclipped extension."
  url "http://github.com/radiant/radiant-assets-extension"
  
  def activate
    Page.send :include, PageAssetAssociations                                          # defines page-asset associations. likely to be generalised soon.
    Radiant::AdminUI.send :include, AssetsAdminUI unless defined? admin.asset          # defines shards for extension of the asset-admin interface
    Admin::PagesController.send :helper, Admin::AssetsHelper                           # currently only provides a description of asset sizes
    Page.send :include, AssetTags                                                      # radius tags for selecting sets of assets and presenting each one
    UserActionObserver.instance.send :add_observer!, Asset                             # the usual creator- and updater-stamping
    
    AssetType.new :image, :mime_types => %w[image/png image/x-png image/jpeg image/pjpeg image/jpg image/gif], :processors => [:thumbnail], :styles => {:icon => ['42x42#', :png], :thumbnail => ['100x100>', :png]}
    AssetType.new :video, :mime_types => %w[video/mpeg video/mp4 video/ogg video/quicktime video/x-ms-wmv video/x-flv]
    AssetType.new :audio, :mime_types => %w[audio/mpeg audio/mpg audio/ogg application/ogg audio/x-ms-wma audio/vnd.rn-realaudio audio/x-wav]
    # AssetType.new :swf, :mime_types => %w[application/x-shockwave-flash]
    # AssetType.new :pdf, :mime_types => %w[application/pdf application/x-pdf]
    # AssetType.new :movie, :mime_types => AssetType.mime_types_for(:video, :swf)        # this is an alias for backwards-compatibility: movie could previously be either video or flash. (existing mime-type lookup table is not affected but methods like Asset#movie? are created)
    AssetType.new :other                                                               #  # an AssetType declared with no (or unknown) mime-types is filed under 'everything else'
    
    admin.asset ||= Radiant::AdminUI.load_default_asset_regions                        # loads the shards defined above
    # admin.page.edit.add :main, "/admin/assets/show_bucket_link", :before => "edit_header"  
    admin.pages.edit.add :part_controls, 'admin/assets/show_bucket_link'   
    admin.page.edit.add :main, "/admin/assets/assets_bucket", :after => "edit_buttons"
    admin.page.edit.asset_tabs.concat %w{attachment_tab upload_tab bucket_tab search_tab}
    admin.page.edit.bucket_pane.concat %w{bucket_notes bucket bucket_bottom}
    admin.page.edit.asset_panes.concat %w{page_attachments upload search}
    
    if Radiant::Config.table_exists? && Radiant::Config["assets.image_magick_path"]    # This is just needed for testing if you are using mod_rails
      Paperclip.options[:image_magick_path] = Radiant::Config["assets.image_magick_path"]
    end
    
    tab "Assets", :after => "Content" do
      add_item "All", "/admin/assets/"
    end
    
    update_sass_each_request if RAILS_ENV == 'development'
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
  
end
