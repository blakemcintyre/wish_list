Rails.application.routes.draw do
  # devise_for :users

  # resources :lists, except: [:show] do
  #   get ":user_id" => "lists#index", on: :collection

  #   patch :remove_claimed
  # end

  # resources :item_claims, except: [:index, :show]
  # resources :categories, only: [:create, :new, :update, :destroy]
  # resources :users

  get '*path', to: 'redirect#index'

  root "redirect#index"
end
