SampleApp::Application.routes.draw do
  get "sessions/new"

  resources :sessions, :only => [:new, :create, :destroy]

  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  resources :microposts, :only => [:create, :destroy]

  resources :relationships, :only => [:create, :destroy]

  resources :users do
    resources :microposts, :only => [:create, :index, :destroy]

    member do
      # Will recognize /users/1/{following|followers} with GET & routes it to "UsersController#{following|followers}"
      # Will create (among other things) the following named route-helpers: {following|followers}_user_path
      get :following, :followers
    end
  end

  match '/signup', :to => 'users#new' 
  # Might not be required
  # get "users/new"



  root :to => 'pages#home'

  #matches '/about' and routes it to the 'about' action in the Pages controller.
  # also it creates named routes for use in the controllers and views:
  #  about_patch => '/about'
  #  about_url => 'http://localhost:3000/about'
  match '/about', :to => 'pages#about'

  match '/contact', :to => 'pages#contact'

  match '/help', :to => 'pages#help'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
