Rails.application.routes.draw do
  # Sidekiq Web UI, only for admins.
  require "sidekiq/web" # A Sinatra service in sidekiq that will generate a dashboard page to monitor jobs
  authenticate :user, lambda { |u| u.admin } do # A user need user.admin = true to access it
    mount Sidekiq::Web => '/sidekiq'
  end

  # the callback routes are defined for omniauth
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'pages#home'
  get 'confidentiality', to: 'pages#confidentiality', as: :confidentiality
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :fans, only: [:index, :show, :new, :create, :update] do
    get :top_fans, on: :collection
    get :new_fans, on: :collection
    get :sleeping, on: :collection
    get :new_loyal_fans, on: :collection
  end

  #MEMOS: no need for a memo view, will be displayed in the fans view.
  resources :memos, only: [:create, :edit, :update]

  # VIDEO : no need for a video view, will be displayed in the fans view.
  # resources :videos, only: [:create, :update]

  # COMMENTS : no need for a comments view, will be displayed in the fans view.
  resources :comments, only: [:update]

  # -----------------------------  API ROUTES  ---------------------------------

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :fans, only: [:index]
      resources :users, only: [:index]
      get 'users/verif'
    end
  end
end
