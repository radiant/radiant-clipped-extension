ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :remove => :get } do |admin|
    admin.resources :assets, :collection => { :refresh => [:post, :get] }
    admin.resources :page_attachments
    admin.resources :pages, :has_many => :page_attachments
  end
end

