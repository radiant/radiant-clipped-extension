require_dependency 'application_controller'
require File.dirname(__FILE__) + '/lib/url_additions'
include UrlAdditions

class AssetsExtension < Radiant::Extension
  version "1.0"
  description "Assets extension based Keith Bingman's original Paperclipped extension."
  url "http://github.com/radiant/radiant-assets-extension"
  
  def activate
    Radiant::AdminUI.send :include, AssetsAdminUI unless defined? admin.asset # UI is a singleton and already loaded
    admin.asset = Radiant::AdminUI.load_default_asset_regions
    
    Admin::PagesController.class_eval {
      helper Admin::AssetsHelper
    }
    
    # admin.page.edit.add :main, "/admin/assets/show_bucket_link", :before => "edit_header"  
    admin.pages.edit.add :part_controls, 'admin/assets/show_bucket_link'   
    admin.page.edit.add :main, "/admin/assets/assets_bucket", :after => "edit_buttons"
    admin.page.edit.asset_tabs.concat %w{attachment_tab upload_tab bucket_tab search_tab}
    admin.page.edit.bucket_pane.concat %w{bucket_notes bucket bucket_bottom}
    admin.page.edit.asset_panes.concat %w{page_attachments upload search}
    
    Page.class_eval {
      has_many :page_attachments, :order => :position
      has_many :assets, :through => :page_attachments
      include AssetPageTags
    }
    
    # Make asset tags available in stylesheets and javascripts
    if defined?(TextAsset)
      TextAsset.send :include, AssetTags
    end
    
    # connect UserActionObserver with my models 
    UserActionObserver.instance.send :add_observer!, Asset 
    
    # This is just needed for testing if you are using mod_rails
    if Radiant::Config.table_exists? && Radiant::Config["assets.image_magick_path"]
      Paperclip.options[:image_magick_path] = Radiant::Config["assets.image_magick_path"]
    end
    
    tab "Assets", :after => "Content" do
      add_item "Home", "/admin/assets/"
    end
  end
  
  def deactivate
    
  end
  
end
