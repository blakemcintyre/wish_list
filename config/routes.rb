Rails.application.routes.draw do
  devise_for :users

  resources :lists, except: [:show] do
    get ':user_id' => 'lists#index', on: :collection
  end

  resources :item_claims, only: [:create, :destroy]
  resources :users

  root 'lists#edit'
end
