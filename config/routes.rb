Pollit::Application.routes.draw do
  devise_for :users, :controllers => {:omniauth_callbacks => 'omniauth_callbacks'}

  post 'nuntium/receive_at' => 'nuntium#receive_at'
  
  resources :polls do
    collection do
      post 'import_form'
    end
  end

  root :to => "home#index"
end
