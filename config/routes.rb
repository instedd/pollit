Pollit::Application.routes.draw do
  get "answers/index"

  devise_for :users, :controllers => {:omniauth_callbacks => 'omniauth_callbacks'}

  post 'nuntium/receive_at' => 'nuntium#receive_at'
  
  resources :polls do
    collection do
      post 'import_form'
    end
    member do
      post 'start'
      post 'register_channel/:ticket_code', :action => 'register_channel'
    end
    resources :respondents, :only => [:index] do
      collection do
        post 'batch_update'
        post 'import_csv'
      end
    end
    resources :answers, :only => [:index]
  end

  root :to => "home#index"
end
