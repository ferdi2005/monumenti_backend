class AuthenticationController < ApplicationController
  def success
    @user = User.find_by(id: session[:user_id])
    @users = User.where(username: @user.username)
  end

  def failure
    redirect_to root_path
  end

  def generate_url(oauth_consumer, sitename)
    # Crea l'url per iniziare una richiesta oauth
    request_token = oauth_consumer.get_request_token(:oauth_callback => "oob")
    session["session_#{sitename}"] = request_token.token
    session["secret_#{sitename}"] = request_token.secret
    

    return request_token.authorize_url(:oauth_callback => "oob")
  end

  def start
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      session[:user_id] = user.id
      @mediawiki_url = generate_url($oauth_consumer, "mediawiki")
      @test_url = generate_url($test_oauth_consumer, "testwiki")
    else
      redirect_to root_path and return
    end
  end

  def process_data(oauth_consumer, user, sitename)
    begin
      hash = { oauth_token: session["session_#{sitename}"], oauth_token_secret: session["secret_#{sitename}"]}
      request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
      access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
      authinfo = {token: access_token.token, secret: access_token.secret}
      
      username = JSON.parse(access_token.get("/w/api.php?action=query&meta=userinfo&uiprop=*&format=json").body)["query"]["userinfo"]["name"]

      user.update!(username: username, authinfo: authinfo, authorized: true, ready: true)

      # Consente gli utenti con più login.      
      User.where(username: username).each do |other_user|
        other_user.update!(authinfo: authinfo)
      end

      redirect_to success_path
    rescue => e
      logger.error e
      redirect_to root_path
    end
  end

  def mediawiki
    user = User.find(session[:user_id])
    if user
      process_data($oauth_consumer, user, "mediawiki")
    else
      redirect_to root_path and return
    end
  end

  def testwiki
    user = User.find(session[:user_id])
    if user
      user.update!(testuser: true)
      process_data($test_oauth_consumer, user, "testwiki")
    else
      redirect_to root_path and return
    end
  end
end