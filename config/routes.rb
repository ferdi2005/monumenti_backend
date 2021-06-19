Rails.application.routes.draw do
  root 'pages#uhm'
  get "start_login", to: 'authentication#start'
  post 'set_credentials', to: 'credentials#set'
  get 'userinfo', to: "credentials#get"
  post "auth/mediawiki/callback", to: "authentication#mediawiki"
  get 'success', to: "authentication#success"
  get 'auth/failure', to: "authentication#failure"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
