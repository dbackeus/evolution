require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  resources :repositories
  resources :dashboards, only: :index
  resources :github_installations, only: %i[index show] do
    collection do
      get :callback
    end
  end
end
