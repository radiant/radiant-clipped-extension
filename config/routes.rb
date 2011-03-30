ActionController::Routing::Routes.draw do |map|

  # Main RESTful routes for Assets
  map.namespace :admin, :member => { :remove => :get }, :collection => { :refresh => :post } do |admin|
    admin.resources :assets
  end
  
  map.with_options(:controller => 'admin/assets') do |asset|
    # asset.refresh_assets    "/admin/assets/:id/refresh",               :action => 'regenerate_thumbnails'
    # asset.reorder_assets    '/admin/assets/reorder/:id',               :action => 'reorder'
    asset.attach_page_asset '/admin/assets/attach/:asset/page/:page',  :action => 'attach_asset'
    asset.remove_page_asset '/admin/assets/remove/:asset/page/:page',  :action => 'detach_asset'
  end    
end

