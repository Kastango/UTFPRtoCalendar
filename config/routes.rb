Rails.application.routes.draw do
  root 'pages#home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "timeline", to: "timeline#index"
  post "timeline", to: "timeline#submit" 
  
  get 'timeline/download_csv', to: 'timeline#download_csv', as: 'download_csv'
end
