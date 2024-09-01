Rails.application.routes.draw do
  resources :memos, only: %i[index show create update destroy] do
    resources :comments, only: %i[create update destroy]
  end
end
