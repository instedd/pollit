Pollit::Application.routes.draw do
  get "answers/index"

  devise_for :users, :controllers => {:registrations => 'users/registrations' } do
    get 'users/registrations/success', :to => 'users/registrations#success' 
  end

  post 'nuntium/receive_at' => 'nuntium#receive_at'
  
  resources :polls do
    collection do
      match 'import_form'
    end
    member do
      post 'start'
      post 'register_channel/:ticket_code', :action => 'register_channel'
      post 'pause'
      post 'resume'
    end
    resources :channels, :only => [:new, :create, :show]
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
