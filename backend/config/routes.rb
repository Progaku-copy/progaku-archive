Rails.application.routes.draw do
  resources :memos, only: %i[index show create update destroy] do
    resources :comments, only: %i[create]
  end

  resources :tags, only: %i[index create update destroy]
end
