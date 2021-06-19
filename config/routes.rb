Rails.application.routes.draw do
  post 'set_credentials', to: 'credentials#set'
  post 'userinfo', to: "credentials#get"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
