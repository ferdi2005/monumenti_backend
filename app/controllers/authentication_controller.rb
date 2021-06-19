class AuthenticationController < ApplicationController
  def success
  end

  def failure
    redirect_to root_path
  end

  def start
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      session[:user_id] = user.id
    else
      redirect_to root_path and return
    end
  end

  def mediawiki
    user = User.find(session[:user_id])
    if user
      user.update!(authinfo: auth_hash)
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

