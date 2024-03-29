# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'

  class ActionDispatch::Routing::Mapper # rubocop: disable Style/ClassAndModuleChildren, Lint/ConstantDefinitionInBlock
    def draw(routes_name)
      instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
    end
  end

  draw(:legacy_routes)

  mount Sidekiq::Web, at: '/sidekiq'
  mount ActionCable.server => '/chatroom'

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD']))
    end
  end

  default_url_options host: ENV['URL_BASE'].sub(%r{/$}, '')

  root 'welcome#index'

  namespace :api, path: '', defaults: { format: 'json' } do
    scope module: 'v1', constraints: ApiConstraints.new(version: 1) do
      resources :banners, only: :index
      namespace :leaderboard do
        get 'posts/:query', action: :posts, as: :posts
        get 'users/:query', action: :users, as: :users
      end

      namespace :user_configuration do
        get 'push_notifications_settings', action: :notifications_settings
        patch 'push_notifications_settings', action: :update_notifications_settings
        patch 'mute_carousel/:post_id', action: :mute_carousel
      end

      resources :comments, only: :none do
        member do
          post 'upvote'
        end
      end

      resources :bookmarks, only: [:create, :destroy, :index], param: :post_id
      resource :paypal_account, only: :update

      namespace :shares do
        post 'posts/:post_id', action: :posts
      end

      get 'request-videos-download', to: 'files_downloads#prepare'
      get 'download-videos/:identifier', to: 'files_downloads#download'

      resources :invitations, only: :none do
        post 'phonebook-sync', on: :collection
      end

      resources :rooms, only: [:create, :index, :show, :update] do
        resources :messages, only: [:create, :index]

        member do
          patch 'last-read-message', action: :last_read_message
          post 'add-members', action: :add_members
          delete 'leave-room', action: :leave_room
        end

        collection do
          get 'suggested-colleagues', action: :suggested_colleagues
        end
      end

      patch 'sessions/player-id', to: 'sessions#player_id'

      # TODO: this is a temp controller/endpoint that should be removed, once 'Auto-join' feature starts syncing room members via WebSockets
      resources :users, only: :show
    end

    # scope module: 'v2', constraints: ApiConstraints.new(version: 2) do
    #   resources :sessions
    # end
  end

  namespace :pn_links, path: '' do
    get '/rooms/:room_id', action: :room_details
    get '/rooms/:room_id/messages/:message_id', action: :message_details
  end

  # namespace :campaigns do
  #   get :recipetube, action: :recipetube
  #   get :cryptotube, action: :cryptotube
  #   get :kpopfam, action: :kpopfam
  #   post :subscribe, action: :subscribe
  # end

  get 'download', to: redirect('https://apps.apple.com/app/1600466655')

  post 'paypal/webhook', to: 'paypal#webhook'
end
