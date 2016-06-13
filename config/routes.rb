Rails.application.routes.draw do
  get '/players' => 'players#index'
  get '/players/new' => 'players#new'
  get '/admin_index' => 'application#admin_index'
  get '/teams' => 'teams#index'
  get '/teams/new' => 'teams#new'
  get '/players/:teams_id' => 'players#show'
  post '/players' => 'players#create'
  post '/teams' => 'teams#create'
  get '/players/:id/edit' => 'players#edit', as: :edit_players 
  get '/players/:id/delete' => 'players#delete', as: :delete_players 
  patch '/players/:id' => 'players#update'
  get '/teams/:id/edit' => 'teams#edit', as: :edit_teams
  get '/teams/:id/delete' => 'teams#delete', as: :delete_teams
  patch '/teams/:id' => 'teams#update'
  get '/login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  get '/signup'  => 'users#new' 
  resources :users
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
