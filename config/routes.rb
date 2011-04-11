ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :remove => :get }, :collection => { :refresh => :post } do |admin|
    admin.resources :assets
    admin.resources :page_attachments, :only => [:new, :create, :destroy], :collection => {:reorder => :get}
    admin.resources :pages, :has_many => {
      :page_attachments => {:only => [:new, :create, :destroy], :collection => {:reorder => :get}}
    }
  end
end

