Rails.application.routes.draw do
  root "staticpages#top"

  get '/auth/line/callback', to: 'oauths#callback'

  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  post '/callback', to: 'line_bot#callback'

  get 'liff', to: 'liff#index'

  get 'fullcalendar', to: 'fullcalendar#index'
end