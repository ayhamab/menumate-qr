Rails.application.routes.draw do
  root 'welcome#index'
  
  devise_for :users

  # Discover Restaurants
  get '/discover', to: 'discoveries#index', as: 'discover'

  # Simplified Onboarding
  get '/onboarding', to: 'onboarding#welcome', as: 'onboarding_welcome'
  get '/onboarding/step1', to: 'onboarding#step1', as: 'onboarding_step1'
  post '/onboarding/step1', to: 'onboarding#create_step1', as: 'onboarding_create_step1'
  get '/onboarding/step2/:restaurant_id', to: 'onboarding#step2', as: 'onboarding_step2'
  post '/onboarding/step2/:restaurant_id', to: 'onboarding#create_step2', as: 'onboarding_create_step2'
  get '/onboarding/step3/:restaurant_id', to: 'onboarding#step3', as: 'onboarding_step3'
  get '/onboarding/step4/:restaurant_id', to: 'onboarding#step4', as: 'onboarding_step4'
  post '/onboarding/complete/:restaurant_id', to: 'onboarding#complete', as: 'onboarding_complete'
  post '/onboarding/skip', to: 'onboarding#skip_onboarding', as: 'skip_onboarding'
  
  get '/restaurants/new', to: 'restaurants#new', as: 'new_restaurant'
  resources :restaurants, except: [:new] do
    member do
      get 'menu', to: 'restaurants#menu', as: 'menu'
      get 'qr_code_png', to: 'restaurants#qr_code_png', as: 'qr_code_png'
      get 'qr_code_svg', to: 'restaurants#qr_code_svg', as: 'qr_code_svg'
    end
    
    # Analytics
    namespace :analytics do
      get '', to: 'analytics#index', as: 'index'
      get 'menu_item/:menu_item_id', to: 'analytics#menu_item', as: 'menu_item'
    end
    
    # Team Management
    resources :restaurant_teams, path: 'team', only: [:index, :new, :create, :edit, :update, :destroy]
    
    # Activity Logs
    resources :activity_logs, only: [:index]
    
    # Menu Items with nested resources
    resources :menu_items do
      resources :menu_item_assignments, only: [:index, :create, :update, :destroy]
      resources :menu_item_comments, only: [:index, :create, :update, :destroy]
      resources :ratings, only: [:create, :index]
      resources :dietary_accuracy_reports, only: [:create, :index]
      member do
        post 'track_click'
        post 'track_order'
      end
    end
    
    # Split Tests
    resources :split_tests do
      member do
        post 'start'
        post 'pause'
        post 'complete'
        post 'apply_winner'
      end
      resources :split_test_variants, except: [:show]
    end
    
    # Recipes
    resources :recipes do
      member do
        get 'scale'
      end
      resources :recipe_ingredients, only: [:create, :update, :destroy]
    end
    
    # Food Waste Analytics
    resources :food_waste_analytics, only: [:index, :show], param: :menu_item_id do
      collection do
        get '', to: 'food_waste_analytics#index', as: 'index'
      end
    end
    
    # Training Modules
    resources :training_modules do
      resources :training_questions, except: [:show]
      resources :training_sessions, only: [:create, :show, :update] do
        member do
          post 'submit'
          post 'answer'
        end
      end
    end
    
    # Locations
    resources :locations, only: [:index, :show] do
      collection do
        get 'find_nearby'
      end
    end
    
    # Compliance Management
    resources :restaurant_regions, only: [:index, :create, :destroy]
    resources :compliance_reports, only: [:index, :show, :create] do
      member do
        post 'generate'
        patch 'share'
      end
      collection do
        get 'check_all'
      end
    end
    resources :menu_item_compliances, only: [:index, :show, :update] do
      collection do
        post 'check_all'
      end
    end
    
    # ML Predictions
    resources :menu_predictions, only: [:index, :show, :create] do
      collection do
        post 'predict_all'
        post 'train_model'
      end
    end
    resources :demographic_data, only: [:index, :show, :new, :create, :edit, :update] do
      collection do
        post 'import'
      end
    end
    
    # Dietary Feedback
    resources :dietary_feedbacks, only: [:index, :show, :new, :create] do
      member do
        post 'resolve'
      end
      collection do
        get 'statistics'
      end
    end
  end
  
  
  # Supplier Routes
  devise_for :suppliers, path: 'suppliers', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'register'
  }
  
  # Consultant Routes
  devise_for :consultants, path: 'consultants', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'register'
  }
  
  namespace :suppliers do
    root 'dashboard#index'
    resources :ingredient_listings
    resources :supplier_promotions
    resources :supplier_contacts, only: [:index, :show, :update] do
      member do
        patch 'mark_read'
      end
    end
    resources :supplier_reviews, only: [:index]
    get 'profile', to: 'profile#show'
    get 'profile/edit', to: 'profile#edit'
    patch 'profile', to: 'profile#update'
  end
  
  # Marketplace Routes (for restaurants)
  namespace :marketplace do
    root 'suppliers#index'
    resources :suppliers, only: [:index, :show] do
      resources :ingredient_listings, only: [:index, :show] do
        member do
          post 'contact'
        end
      end
      resources :supplier_reviews, only: [:index, :create]
      member do
        post 'contact'
      end
    end
    resources :promotions, only: [:index, :show]
    resources :categories, only: [:index, :show]
  end
  
  # Consultant Routes
  namespace :consultants do
    root 'dashboard#index'
    resources :clients, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        patch 'pause'
        patch 'activate'
        patch 'terminate'
      end
      resources :restaurants, only: [:show] do
        resources :menu_items, only: [:index, :show, :edit, :update] do
          resources :consultant_notes, only: [:index, :create, :update, :destroy]
        end
        resources :consultant_notes, only: [:index, :create, :update, :destroy]
        resources :consultant_tasks, only: [:index, :create, :update, :destroy] do
          member do
            patch 'complete'
            patch 'start'
          end
        end
        resources :consultant_reports, only: [:index, :show, :create, :update, :destroy] do
          member do
            patch 'share'
          end
        end
        member do
          get 'analytics'
          get 'menu_analysis'
        end
      end
    end
    resources :consultant_notes, only: [:index]
    resources :consultant_tasks, only: [:index]
    resources :consultant_reports, only: [:index]
    get 'profile', to: 'profile#show'
    get 'profile/edit', to: 'profile#edit'
    patch 'profile', to: 'profile#update'
  end
  
  # Compliance Routes (Admin)
  namespace :compliance do
    resources :dietary_laws
    resources :regions do
      resources :region_dietary_laws, only: [:create, :destroy]
    end
    resources :compliance_reports, only: [:index, :show]
  end

  # Franchise Management Routes
  namespace :franchise do
    resources :menu_templates do
      resources :menu_template_items, except: [:show]
      resources :menu_syncs, only: [:index, :show, :create] do
        member do
          post 'execute'
          post 'cancel'
        end
        collection do
          post 'sync_all'
        end
      end
      resources :location_menu_overrides, only: [:index, :show, :new, :create, :edit, :update] do
        member do
          post 'approve'
          post 'reject'
        end
      end
      member do
        post 'activate'
        post 'archive'
        post 'create_version'
        post 'sync_to_locations'
      end
    end
    resources :menu_consistency_reports, only: [:index, :show, :create] do
      collection do
        post 'generate'
      end
    end
  end
end
