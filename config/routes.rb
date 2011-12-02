Pollit::Application.routes.draw do
  
  scope "(:locale)", :locale => /#{Locales.available.keys.join('|')}/ do

    devise_for :users, :controllers => {:registrations => 'users/registrations' } do
      get 'users/registrations/success', :to => 'users/registrations#success' 
    end

    get  'createAccount', :to => redirect('/users/sign_up')
    get  'discuss',       :to => redirect(Pollit::Application.config.user_group_url)
    get  'backlog',       :to => redirect(Pollit::Application.config.backlog_url)

    get 'help',         :action => :index, :controller => :help,      :as => 'help'
    get 'tour(/:page)', :action => :show,  :controller => :tour,      :as => 'tour'
    get 'community',    :action => :index, :controller => :community, :as => 'community'

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
      
      resource :channel, :only => [:show, :new, :create, :destroy]
      
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

    match '/locale/update' => 'locale#update',  :as => 'update_locale'
    match '/' => 'home#index',                  :as => 'home'
  end

  root :to => 'home#index'
end
