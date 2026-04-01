Rails.application.routes.draw do
  devise_for :users

  root "dashboard#show"

  # Daily view with date parameter
  get "day/:date", to: "dashboard#show", as: :day,
      constraints: { date: /\d{4}-\d{2}-\d{2}/ }

  resources :tasks do
    member do
      post :complete
      post :reopen
      post :schedule
      post :unschedule
    end
    collection do
      patch :reorder
    end
  end

  resource :backlog, only: [ :show ]

  resources :channels
  resources :contexts, except: [ :show ]
  resources :weekly_objectives, except: [ :show ]

  resources :working_sessions, only: [ :create, :update, :destroy ]
  resources :documents, only: [ :index, :show, :create, :destroy ]

  # Timer
  post   "timer/start",   to: "timer_sessions#start",   as: :timer_start
  post   "timer/stop",    to: "timer_sessions#stop",     as: :timer_stop
  get    "timer/current",  to: "timer_sessions#current",  as: :timer_current

  # Planning rituals
  get  "plan/morning/:date",  to: "daily_plans#morning",  as: :morning_plan
  post "plan/morning/:date",  to: "daily_plans#complete_morning"
  get  "plan/shutdown/:date", to: "daily_plans#shutdown",  as: :shutdown_plan
  post "plan/shutdown/:date", to: "daily_plans#complete_shutdown"
  post "plan/rollover/:date", to: "daily_plans#rollover", as: :rollover

  # Google Calendar OAuth
  get    "auth/google_calendar",          to: "google_calendar#authorize",  as: :auth_google_calendar
  get    "auth/google_calendar/callback", to: "google_calendar#callback"
  delete "auth/google_calendar",          to: "google_calendar#disconnect"
  post   "auth/google_calendar/sync",     to: "google_calendar#sync"

  # Settings
  resource :settings, only: [ :show, :update ]

  # API
  namespace :api do
    namespace :v1 do
      resources :tasks do
        member do
          post :complete
          post :reopen
          post :schedule
          post :unschedule
        end
        collection do
          get :today
          get :backlog
        end
      end
      resources :channels, only: [ :index, :show, :create, :update, :destroy ]
      resources :contexts, only: [ :index, :create, :update, :destroy ]
      resources :weekly_objectives, only: [ :index, :create, :update, :destroy ]
      resources :calendar_events, only: [ :index ]
      resources :working_sessions, only: [ :index, :create, :update, :destroy ]

      resource :timer, only: [], controller: "timer" do
        post :start
        post :stop
        get :current
      end

      get "daily_plans/:date", to: "daily_plans#show"
      post "daily_plans/:date/rollover", to: "daily_plans#rollover"

      get "search", to: "search#index"
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
