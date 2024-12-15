Rails.application.routes.draw do
  get "attempts/new"
  get "attempts/create"
  get "attempts/show"
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :quizzes do
    resources :questions, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] 
    resources :attempts, only: [:new, :create, :show]
    resources :questions, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
    member do # custom POST route for submitting a specified quiz for scoring at /quizzes/:id/submit
      post :submit
    end
    # Nested routes for attempts under quizzes
    resources :attempts, only: [ :new, :create, :show, :destroy ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "quizzes#index"
end
