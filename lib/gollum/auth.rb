# ~*~ encoding: utf-8 ~*~

require 'omniauth-openid'
require 'openid'
require 'openid/store/filesystem'
require 'gapps_openid'

OmniAuth.config.on_failure = Proc.new{|env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

module Precious
  class App < Sinatra::Base

    OmniAuthProviderSetup = lambda do |env|
      {
        :name => 'gapps',
        :identifier => "https://www.google.com/accounts/o8/site-xrds?hd=#{App.auth_domain}",
        :store => OpenID::Store::Filesystem.new('/tmp/sessions')
      }
    end

    use Rack::Session::Cookie, :secret => 'supers3cr3t'
    use OmniAuth::Builder do
      provider :open_id, :setup => OmniAuthProviderSetup
    end

    post '/auth/gapps/callback' do
      auth_details = request.env['omniauth.auth']
      session[:name]  = auth_details.info['name']
      session[:email] = auth_details.info['email']
      redirect '/auth/gapps/welcome'
    end

    get '/auth/gapps/welcome' do
      if (session['email'] || session['name'])
        redirect '/'
      else
        redirect '/auth/gapps'
      end
    end

    get '/auth/signout' do
      session.clear
      'signout completed.'
      redirect '/'
    end

    get '/auth/failure' do
      params['message']
      # do whatever you want here.
    end
  end
end

