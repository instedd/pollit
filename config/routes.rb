Pollit::Application.routes.draw do
  get "answers/index"

  devise_for :users

  post 'nuntium/receive_at' => 'nuntium#receive_at'
  
  resources :polls do
    collection do
      post 'import_form'
    end
    member do
      post 'start'
      post 'register_channel/:ticket_code', :action => 'register_channel'
    end
    
    resources :channels, :path => :channel, :only => [:create, :destroy]    
    get 'channel/(/:step)' => 'channels#new', :as => 'new_channel'
    
    resources :respondents, :only => [:index] do
      collection do
        post 'batch_update'
        post 'import_csv'
      end
    end
    resources :answers, :only => [:index]
  end

   match 'tour/:page_number' => 'tour#show', :as => :tour

  root :to => "home#index"
end
