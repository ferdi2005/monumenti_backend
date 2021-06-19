class CredentialsController < ApplicationController
  def set
    user = User.new(uuid: params[:uuid], device_name: params[:device_name], token: params[:token])
    if user.save
      respond_to do |format|
        format.json { render :status => 202, :json => {id: user.id }}
      end
    else
      respond_to do |format|
        format.json { render :status => 400, :json => {id: nil}}
      end
    end
  end

  def get
    user = User.find_by(uuid: params[:uuid], token: params[:token])
    if user
      respond_to do |format|
        format.json { render :status => 200, :json => user }
      end
    else
      respond_to do |format|
        format.json { render :json => { error: "User not found."} }
      end
    end
  end
end
