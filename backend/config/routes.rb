Rails.application.routes.draw do
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  namespace :admin do
    resources :users, only: %i[create]
  end

  resources :memos, only: %i[index show create update destroy] do
    resources :comments, only: %i[create update destroy]
  end

  resources :tags, only: %i[index create update destroy]
end
