Rails.application.routes.draw do
  devise_for :users

  resources :lists, except: [:show] do
    get ":user_id" => "lists#index", on: :collection

    patch :remove_claimed

    resources :categories, only: [:create, :new, :update, :destroy]
  end

  resources :item_claims, except: [:index, :show]
  resources :users

  root "lists#edit"
end
