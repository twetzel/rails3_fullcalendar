Calendar::Application.routes.draw do
  
  resources :events

  # => get "calendar/index"
  resources :calendar, :only => :index

  root :to => "calendar#index"

end
