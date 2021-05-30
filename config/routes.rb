Rails.application.routes.draw do 
  resources :accounts
  resources :playerstats
  resources :timers
  resources :models
  resources :notifications

  get 'password_resets/new'

  get 'password_resets/edit'

  get '/players' => 'players#index'
  get '/timers/new' => 'timers#new'
  get '/players/new' => 'players#new'
  get '/bids/new' => 'bids#new'
  get '/bids/showall' => 'bids#showall'
  get '/bids' => 'bids#index'
  get '/bids' => 'bids#subtract_amount'
  get '/bids/:id/edit' => 'bids#edit', as: :edit_bids 
  post '/bids' => 'bids#create'
  get '/admin_index' => 'application#admin_index'
  get '/teams' => 'teams#index'
  get '/teams/new' => 'teams#new'
  get '/players/:teams_id' => 'players#show'
  get '/teamsheet/calculate_score' => 'teamsheet#calculate_score'
  post '/players' => 'players#create'
  post '/teams' => 'teams#create'
  get '/players/:id/edit' => 'players#edit', as: :edit_players 
  get '/players/:id/delete' => 'players#delete', as: :delete_players 
  get '/bids/:id/delete' => 'bids#delete', as: :delete_bids 
  get '/bids/transferOut' => 'bids#transferOut', as: :transfer_out_bids
  get '/notifications/:id/destroy' => 'notifications#destroy', as: :delete_notifications_path 
  patch '/players/:id' => 'players#update'
  patch '/teamsheet/:id' => 'teamsheet#update'
  patch '/results_masters/:id' => 'results_masters#update'
  get '/teams/:id/edit' => 'teams#edit', as: :edit_teams
  get '/teams/:id/delete' => 'teams#delete', as: :delete_teams
  get '/bids/checkBids' => 'bids#checkBids'
  get '/bids/insertWinners' => 'bids#insertWinners'
  get '/teamsheet/index' => 'teamsheet#index'
  get '/results_masters/admin_edit' => 'results_masters#admin_edit', as: :admin_edit_results_masters
  get '/results_masters/:id/edit' => 'results_masters#edit', as: :edit_results_masters
  get '/results_masters/edit_multiple' => 'results_masters#edit_multiple'
  get '/results_masters/index' => 'results_masters#index'
  get 'results_masters/show' => 'results_masters#show'
  get 'results_masters/reset_results' => 'results_masters#reset_results'
  get 'results_masters/copy_results' => 'results_masters#copy_results'
  get 'results_masters/copy_results_to_teamsheets' => 'results_masters#copy_results_to_teamsheets'
  get '/teamsheet/admin_edit' => 'teamsheet#admin_edit', as: :admin_edit_teamsheet
  get '/teamsheet/:id/edit' => 'teamsheet#edit', as: :edit_teamsheet
  get '/teamsheet/:user_id/show' => 'teamsheet#show'
  get '/teamsheet/stats' => 'teamsheet#stats'
  patch '/teams/:id' => 'teams#update'
  get '/login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  get 'logout' => 'sessions#destroy'
  get '/signup'  => 'users#new' 
  get '/index' => 'application#index'
  get '/edit_profile' => 'sessions#show'
  get '/sessions/:id/edit' => 'sessions#edit', as: :edit_users
  get '/fixtures/createFixtures' => 'fixtures#createFixtures'
  get '/results/fixture_results' => 'results#fixture_results'
  get '/sessions/squad_validity_check' => 'sessions#squad_validity_check'
  get '/results/updateLeagueTable' => 'results#updateLeagueTable'
  get '/league_table/updateLeagueTable' => 'league_table#updateLeagueTable'
  get '/league_table/viewLeagueTable' => 'league_table#viewLeagueTable'
  get '/teamsheets/edit_multiple' => 'teamsheet#edit_multiple'
  get '/manage_permissions' => 'application#manage_permissions'
  get '/manage_permissions_on' => 'application#manage_permissions_on'
  get '/manage_permissions_off' => 'application#manage_permissions_off'
  get '/notification_settings_on' => 'application#notification_settings_on'
  get '/notification_settings_off' => 'application#notification_settings_off'
  get '/fixtures/index' => 'fixtures#index', as: :user_fixtures_path
  get '/admin_controls' => 'application#admin_controls'
  get '/uffl' => 'application#uffl'
  get '/rules' => 'application#rules'
  get '/sessions/calculate_results' => 'sessions#calculateMatchdayResults'
  get '/admin_db' => 'application#admin_db'
  get '/teamsheet/index2' => 'teamsheet#index2'
  get '/playerstats/:id' => 'playerstats#show', as: :show_player_stats_path
  get '/signup_options' => 'users#signup_options', as: :signup_options_path
  patch '/sessions/:id' => 'sessions#update'
  patch '/bids/:id' => 'bids#update'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  root to: 'application#uffl'
  resources :teamsheet do
    collection do
      post :edit_multiple
      put :update_multiple
end
end
resources :results_masters do
  collection do
    post :edit_multiple
    put :update_multiple
end
end
  
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
