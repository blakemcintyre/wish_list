Rails.application.routes.draw do
  devise_for :users

  resources :lists, except: [:show] do
    resources :items, except: %i(show)

    patch :remove_claimed, on: :member

    resources :categories, only: [:create, :new, :update, :destroy]
    get 'claimable', to: 'item_claims#index'
  end

  resources :item_claims, except: [:index, :show]
  resources :users

  root "lists#index"
end
