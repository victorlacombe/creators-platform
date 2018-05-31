Rails.application.routes.draw do
  # the callback routes are defined for omniauth
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'pages#home'
  get 'confidentiality', to: 'pages#confidentiality', as: :confidentiality
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :fans, only: [:index, :show, :new, :create, :update]

  #MEMOS: no need for a memo view, will be displayed in the fans view.
  resources :memos, only: [:create, :edit, :update]

  # VIDEO : no need for a video view, will be displayed in the fans view.
  resources :videos, only: [:create, :update]

  # COMMENTS : no need for a comments view, will be displayed in the fans view.
  resources :comments, only: [:create, :update]

  # -----------------------------  API ROUTES  ---------------------------------

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :memos, only: [:index]
      resources :fans, only: [:index]
      resources :videos, only: [:index]
      resources :comments, only: [:index]
    end
  end
end
