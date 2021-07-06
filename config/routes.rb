Rails.application.routes.draw do
  root 'pages#uhm'
  get "start_login", to: 'authentication#start'
  post 'set_credentials', to: 'credentials#set'
  get 'userinfo', to: "credentials#get"
  get "auth/mediawiki/callback", to: "authentication#mediawiki"
  get 'success', to: "authentication#success"
  get 'auth/failure', to: "authentication#failure"
  get 'deleteuser', to: "credentials#delete"
  post 'photoupload', to: "photos#upload"
  get 'photolist', to: "photos#index"
  post 'set_title', to: "photos#title"
  post "photocancel", to: "photos#cancel"
  get 'auth/testwiki/callback', to: "authentication#testwiki"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
