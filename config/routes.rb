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
    
    resources :channels, :path => :channel, :only => [:new, :create, :destroy]    
    
    get 'channel(/:step)' => 'channels#new', :as => 'new_channel'

    resources :respondents, :only => [:index] do
      collection do
        post 'batch_update'
        post 'import_csv'
      end
    end

    resources :answers, :only => [:index] do
      collection do
        get 'page/:page', :action => :index
      end
    end
  end

  match 'tour/:page_number' => 'tour#show', :as => :tour

  root :to => "home#index"
end
