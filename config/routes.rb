Rails.application.routes.draw do
  resources :dashboards, only: :index
end
