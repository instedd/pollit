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
        post 'register_phone_channel/:ticket_code', :action => 'register_phone_channel'
        post 'pause'
        post 'resume'
      end

      resource :channel, :only => [:show, :new, :create, :destroy]
      resource :phone_channel, :only => [:new, :create]
      resource :twitter_channel, :only => [:new, :create] do
        get 'twitter_callback'
      end
      resource :twilio_channel, :only => [:new, :create]

      resources :respondents, :only => [:index] do
        collection do
          post 'batch_update'
          post 'import_csv'
          get 'export_csv'
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

  match '/twilio/callback' => 'twilio_channels#callback'

  root :to => 'home#index'
end
