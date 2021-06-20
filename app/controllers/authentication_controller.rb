class AuthenticationController < ApplicationController
  def success
  end

  def failure
    redirect_to root_path
  end

  def start
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      session[:user_id] = user.id
      oauth_consumer = OAuth::Consumer.new(ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"], :site => "https://commons.wikimedia.org", :request_token_path => "/w/index.php?title=Special:OAuth/initiate", :authorize_path => "/wiki/Special:OAuth/authorize", :access_token_path => "/wiki/Special:OAuth/token",)
      request_token = oauth_consumer.get_request_token(:oauth_callback => "oob")
      session[:token] = request_token.token
      session[:token_secret] = request_token.secret
      redirect_to request_token.authorize_url(:oauth_callback => "oob")
    else
      redirect_to root_path and return
    end
  end

  def mediawiki
    user = User.find(session[:user_id])
    if user
      hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret]}
      request_token  = OAuth::RequestToken.from_hash(oauth_consumer, hash)
      access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
      user.update!(authinfo: access_token)
    else
      redirect_to root_path and return
    end
    redirect_to success_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

