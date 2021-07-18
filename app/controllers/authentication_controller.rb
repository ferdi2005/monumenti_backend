class AuthenticationController < ApplicationController
  def success
    @user = User.find_by(id: session[:user_id])
  end

  def failure
    redirect_to root_path
  end

  def generate_url(oauth_consumer)
    # Crea l'url per iniziare una richiesta oauth
    request_token = oauth_consumer.get_request_token(:oauth_callback => "oob")
    session[:token] = request_token.token
    session[:token_secret] = request_token.secret
    return request_token.authorize_url(:oauth_callback => "oob")
  end

  def start
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      session[:user_id] = user.id
      @mediawiki_url = generate_url($oauth_consumer)
      @test_url = generate_url($test_oauth_consumer)
    else
      redirect_to root_path and return
    end
  end

  def process_data(oauth_consumer, user)
    begin
      hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret]}
      request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
      access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
      authinfo = {token: access_token.token, secret: access_token.secret}
      user.update!(authinfo: authinfo, authorized: true)
      GetUserInfoWorker.perform_async(user.id)
      redirect_to success_path
    rescue
      redirect_to root_path
    end
  end

  def mediawiki
    user = User.find(session[:user_id])
    if user
      process_data($oauth_consumer, user)
    else
      redirect_to root_path and return
    end
  end

  def testwiki
    user = User.find(session[:user_id])
    if user
      user.update!(testuser: true)
      process_data($test_oauth_consumer, user)
    else
      redirect_to root_path and return
    end
  end
end