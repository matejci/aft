# frozen_string_literal: true

scope '', path: '', constraints: ApiConstraints.new(version: 0) do
  resources :pools

  resources :pool_intervals do
    member { patch :process_interval }
  end

  resources :usernames do
    collection { post :manage }

    member do
      patch :claim
      patch :make_searchable
    end
  end

  resource :dashboard, controller: 'dashboard', only: :none do
    collection do
      post :index
      get 'payouts/p/:page', to: 'dashboard#payouts'
    end
  end

  resource :views, only: :none do
    collection do
      post :data
      post :events_data
    end
  end

  namespace :feed do
    get '/home', action: :index
    get '/discover', action: :discover
    get '/explore', action: :explore
  end

  resource :autocomplete, controller: 'autocomplete', only: :none do
    get :hashtags
    get :usernames
  end

  resources :mentions
  resources :hashtags
  resources :categories

  resources :posts do
    resources :comments do
      member { put :phantom }
    end

    member do
      post :upvote
      # post :downvote # not used since IOS app v.1.3.0.3
    end
  end

  resources :posts, path: '/p', only: %i[show update], param: :link, as: :p do
    member do
      post :report
    end

    post '/v/:event', to: 'views#event', constraints: EventConstraint, as: :event
  end

  get '/embed/example', to: 'welcome#embed'
  get '/embed/:link', to: 'posts#embed'

  get 'posts/:id/takkos', to: 'posts#takkos'

  namespace :search do
    get '/', action: :index
    get 'posts', action: :posts
    get 'users', action: :users
    get 'hashtags'
  end

  resources :invitations
  resources :apps, only: [:index, :show, :edit, :update] do
    get 'configuration', on: :collection
  end

  resources :users, except: %i[update destroy] do
    patch :update_password, on: :member
  end

  resources :user_groups, except: %i[new edit]
  resource :user_configuration, only: [:show, :update]

  resource :user, only: :update, as: '' do
    get 'blocked_accounts/p/:page', action: :blocked_accounts
    post :authenticate, defaults: { format: :json }
    post :remove_account
  end

  resource :reset_password, controller: 'reset_password', only: %i[new create] do
    post :send_email
    get 'token/:token', action: :reset_link, as: :link
  end

  resource :verification, controller: 'verification', only: :none do
    post :send_code
    post :verify_code
    get 'token/:token', action: :verify_email, as: :email
  end

  resources :sessions
  resources :subscribers

  resources :profiles, only: :show, param: :username do
    member do
      post   :follow
      delete :unfollow
      post   :block
      delete :unblock
      get    'followers/p/:page', action: :followers
      get    'followees/p/:page', action: :followees
      get    :user
      get '/:posts/p/:page', action: :posts, constraints: { posts: Regexp.new(/(?:posts|takkos|private)/) }, as: :posts
      get :feed
    end
  end

  post '/reports/:entity', to: 'reports#entity'

  resources :notifications, only: :none do
    collection do
      get 'p/:page', action: :index
      patch :mark_as_read
      post :aws
    end
  end

  constraints subdomain: 'www' do
    match '(*any)', to: redirect(subdomain: ''), via: :all
  end

  # unsubscribe route
  # http://www.takkoapp.com/email/unsubscribe/@subscriber.unsubscribe_hash
  get '/email/unsubscribe/:unsubscribe_hash', to: 'subscribers#unsubscribe'

  get '/settings', to: 'users#edit'

  # share route
  get '/s/:link', to: 'subscribers#share'

  post '/current/user/session', to: 'users#current_user_session'
  get '/signup', to: 'users#new'
  get '/signout', to: 'sessions#destroy'
  get '/login', to: 'sessions#new'

  # admin studio routes
  get '/admin', to: 'admin#index'
  get '/admin/studio', to: 'admin#studio'
  get '/admin/studio/*path', to: 'admin#studio'
  get '/admin/sessions', to: 'admin#sessions'
  get '/admin/invitations', to: 'admin#invitations'
  get '/admin/creator_program', to: 'admin#creator_program'
  post '/admin/creator_program_toggle', to: 'admin#creator_program_toggle'

  namespace :admin do
    namespace :boost_list do
      get 'index'
      get 'search'
      patch 'add'
      delete 'remove'
      patch 'boost_value_update'
      patch 'post_boost_value_update'
    end

    resources :banners, except: :show
    resources :curated_posts, only: [:index, :destroy, :update] do
      collection do
        get 'search'
      end
    end

    resources :reports, only: [:index, :show, :update]
    resources :users, only: :none do
      member do
        post :verify
      end
    end

    resources :contests, only: [:index, :create, :update]
  end

  namespace :creator_program do
    get 'status', action: 'status'
    post 'opt_in', action: 'opt_in'
  end

  post '/usernames/csv', to: 'usernames#upload'

  # admin studio metrics
  post '/admin/metrics/dashboard', to: 'admin#dashboard_metrics'

  # apple
  get '/apple-app-site-association', to: 'welcome#apple_app_site_association'
  get '/.well-known/apple-app-site-association', to: 'welcome#apple_app_site_association'

  get '/widget', to: 'posts#widget'
  get '/util/env', to: 'welcome#env'

  get '/terms', to: 'welcome#terms'
  get '/privacy', to: 'welcome#privacy'
  get '/cookies', to: 'welcome#cookies'
  get '/guidelines', to: 'welcome#guidelines'
  get '/tutorial', to: 'welcome#tutorial'
  get '/keep_in_touch', to: 'welcome#index'

  if Rails.env.in?(%w[test development]) || ENV['HEROKU_ENV'].in?(%w[dev staging])
    namespace :admin do
      get 'users'
    end

    resources :users, only: :destroy

    get '/hls_testing', to: 'welcome#hls'
    get '/api/docs', to: 'welcome#api_docs', as: 'api_docs'
  end
end
