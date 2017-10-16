Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'builds#index'

  resources :builds, only: %w(index create)

  namespace :build, path: '/builds', module: nil do
    scope '/:namespace' do
      resources '', controller: 'builds', only: %w(show update destroy)
    end
  end
end
