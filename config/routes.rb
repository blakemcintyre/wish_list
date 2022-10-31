Rails.application.routes.draw do
  devise_for :users

  resources :lists, except: [:show] do
    resources :items, only: %i(index create)

    patch :remove_claimed, on: :member

    resources :categories, only: %i(index create new update destroy)
    get 'claimable', to: 'item_claims#index'
  end

  resources :categories, only: %i(edit update)
  resources :items, only: %i(edit update destroy create)
  resources :item_claims, except: [:index, :show]
  resources :users

  root "lists#index"
end
