Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :fans, only: [:index, :show, :new, :create, :update]

  #MEMOS: no need for a memo view, will be displayed in the fans view.
  resources :memos, only: [:create, :edit, :update]

  # VIDEO : no need for a video view, will be displayed in the fans view.
  resources :videos, only: [:create, :update]

  # COMMENTS : no need for a comments view, will be displayed in the fans view.
  resources :comments, only: [:create, :update]
end
