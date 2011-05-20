ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :remove => :get } do |admin|
    admin.resources :assets, :collection => { :refresh => :get, :regenerate => :post }, :member => { :refresh => :put }
    admin.resources :page_attachments, :only => [:new]
    admin.resources :pages, :has_many => :page_attachments
  end
end

