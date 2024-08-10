Rails.application.routes.draw do
  devise_for :admin_users
  resources :memos, only: %i[index show create update destroy] do
    resources :comments, only: %i[create]
  end
end
