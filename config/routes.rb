ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users
  map.resources :config_items
  map.resources :hosts, :member => { :disable => :get, :enable => :get }, :collection => {:get_sub_form => :get, :get_sub_form_host_form => :get} do |host|
    host.resources :schedules, :member => { :disable => :get, :enable => :get }, :collection => {:get_on_form => :get}, :has_one => :retention_policy, :has_many => :stats
    host.resources :restores do |restore|
      restore.resources :schedules do |schedule|
        schedule.resources :file_indices, :collection => { :get_file_index => :post}, :member => { :add => :post, :remove => :delete, :finish => :post }
      end
    end
  end
  map.resources :jobs, :member => { :update_status => :post }
  map.resources :nodes, :has_many => :stats
  map.resources :settings
  map.root :controller => "hosts"
end
