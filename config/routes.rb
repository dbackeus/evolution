Rails.application.routes.draw do
  resources :dashboards, only: :index
  resources :github_installations, only: %i[index show] do
    collection do
      get :callback
    end
  end
end
