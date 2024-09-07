Rails.application.routes.draw do
  namespace :admin do
    resources :users, only: %i[create]
  end

  resources :memos, only: %i[index show create update destroy] do
    resources :comments, only: %i[create update destroy]
  end
end
