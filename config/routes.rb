Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "repositories#index"

  get '/repositories/search', to: 'repositories#search'
end
