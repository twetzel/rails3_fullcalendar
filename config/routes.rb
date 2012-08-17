Calendar::Application.routes.draw do
  
  resources :people

  resources :events

  # => get "calendar/index"
  resources :calendar, :only => [:index, :show]

  root :to => "calendar#index"

end
