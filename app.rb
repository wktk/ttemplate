require 'oauth'
require 'sinatra/base'
require 'slim'
require 'twitter'
require './models'

class App < Sinatra::Base

  configure do
    enable :sessions
  end

  helpers do

    # Returns an oauth consumer object using the consumer given thru ENV
    #
    # @return [OAuth::Consumer]
    def oauth
      @oauth ||= OAuth::Consumer.new(
        ENV['TWITTER_CONSUMER_KEY'],
        ENV['TWITTER_CONSUMER_SECRET'],
        site: 'https://api.twitter.com'
      )
    end

    # Returns an object of the authenticated user
    #
    # @return [nil] if not logged-in
    # @return [User]
    def user
      return nil unless session[:id]
      @user ||= User.get(session[:id])
    end

    # Returns a user is logged in or not
    #
    # @return [Boolean]
    alias logged_in? user

  end

  get '/' do
    slim logged_in? ? :home : :welcome
  end

  get '/login' do
    request_token = oauth.get_request_token(oauth_callback: to('/callback'))
    session[:oauth_secret] = request_token.secret
    redirect request_token.authorize_url
  end

  get '/callback' do
    access_token = OAuth::RequestToken.new(
      oauth, params[:oauth_token], session.delete(:oauth_secret)
    ).get_access_token(oauth_verifier: params[:oauth_verifier])
    session[:id] = User.login(access_token)
    redirect to '/'
  end

  post '/logout' do
    session.delete(:id)
    redirect to('/')
  end

end
