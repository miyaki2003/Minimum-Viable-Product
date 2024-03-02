Rails.application.routes.draw do
  get 'staticpages/top'

  root "staticpages#top"
  
  resources :calendars, only: %i[index]

  get 'oauth/callback', to: 'oauths#callback'
end