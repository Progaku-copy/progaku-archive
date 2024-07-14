Rails.application.routes.draw do
  resources :tests, only: %i[index]
  resources :memos, only: %i[index show create update destroy] do
    collection do
        get 'search'
    end
  end
end
