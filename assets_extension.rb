require_dependency 'application_controller'
require File.dirname(__FILE__) + '/lib/url_additions'
include UrlAdditions

class AssetsExtension < Radiant::Extension
  version "0.8.1"
  description "Assets extension based Keith Bingman's original Paperclipped extension."
  url "http://github.com/radiant/radiant-assets-extension"
  
  def activate
    Radiant::AdminUI.send :include, AssetsAdminUI unless defined? admin.asset # UI is a singleton and already loaded
    admin.asset = Radiant::AdminUI.load_default_asset_regions
    
    Admin::PagesController.class_eval {
      helper Admin::AssetsHelper
    }

    %w{page}.each do |view|
      # admin.send(view).edit.add :main, "/admin/assets/show_bucket_link", :before => "edit_header"  
      admin.pages.edit.add :part_controls, 'admin/assets/show_bucket_link'   
      admin.send(view).edit.add :main, "/admin/assets/assets_bucket", :after => "edit_buttons"
      admin.send(view).edit.asset_tabs.concat %w{attachment_tab upload_tab bucket_tab search_tab}
      admin.send(view).edit.bucket_pane.concat %w{bucket_notes bucket bucket_bottom}
      admin.send(view).edit.asset_panes.concat %w{page_attachments upload search}
    end
    
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
    
    tab 'Content' do
      add_item I18n.translate("paperclipped.assets_title"), "/admin/assets", :after => "Pages"
    end
  end
  
  def deactivate
    
  end
  
end
