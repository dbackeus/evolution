require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  resource :session, only: %i[create destroy]

  resources :charts
  resources :commits, only: :show
  resources :filters
  resources :repositories
  resources :dashboards, only: :index
  resources :github_installations, only: %i[index show] do
    collection do
      get :callback
    end
  end

  root to: "sessions#new"
end
