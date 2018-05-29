Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'confidentiality', to: 'pages#confidentiality', as: :confidentiality

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
