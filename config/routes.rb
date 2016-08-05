# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

Pollit::Application.routes.draw do

  mount InsteddTelemetry::Engine => '/instedd_telemetry'

  namespace "api" do
    resources :polls, :only => [:index, :show] do
      resources :questions,   :only => [:index, :show]
      resources :respondents, :only => [:index, :show]
      resources :answers,     :only => [:index, :show]
    end
  end

  scope "(:locale)", :locale => /#{Locales.available.keys.join('|')}/ do

    devise_for :users, :controllers => {:registrations => 'users/registrations', omniauth_callbacks: "omniauth_callbacks" } do
      get 'users/registrations/success', :to => 'users/registrations#success'
    end

    guisso_for :user

    get  'createAccount', :to => redirect('/users/sign_up')
    get  'discuss',       :to => redirect(Pollit::Application.config.user_group_url)
    get  'backlog',       :to => redirect(Pollit::Application.config.backlog_url)

    get 'help',         :action => :index, :controller => :help,      :as => 'help'
    get 'tour(/:page)', :action => :show,  :controller => :tour,      :as => 'tour'
    get 'community',    :action => :index, :controller => :community, :as => 'community'

    post 'nuntium/receive_at' => 'nuntium#receive_at'
    post 'nuntium/delivery_callback' => 'nuntium#delivery_callback'

    resources :channels, :only => [:index, :new, :create, :destroy]

    resources :polls do
      collection do
        get   'new/manual', action: 'new_manual'
        get   'new/gforms', action: 'new_gforms'
        match 'import_form'
      end

      member do
        post 'start'
        post 'register_channel/:ticket_code', :action => 'register_channel'
        post 'pause'
        post 'resume'
        post 'duplicate'

        post 'run_next_job'
      end

      resources :respondents, :only => [:index, :destroy] do
        collection do
          post 'add_phones'
          post 'delete_all'
          post 'import_csv'
          post 'clear_hub'
          post 'connect_hub'
        end
      end

      resources :answers, :only => [:index]

      resources :summary, :only => [:index] do
        collection do
          get 'query/:question_id', :action => :query, :as => 'query'
        end
      end
    end

    match '/hub/*path' => 'hub#api', format: false
    match '/locale/update' => 'locale#update',  :as => 'update_locale'
    match '/' => 'home#index',                  :as => 'home'
  end

  root :to => 'home#index'

  mount Listings::Engine => "/listings"
end
