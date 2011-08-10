Pollit::Application.routes.draw do
  devise_for :users

  post 'nuntium/receive_at' => 'nuntium#receive_at'
  root :to => "home#index"
end
