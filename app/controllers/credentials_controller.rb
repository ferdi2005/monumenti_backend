class CredentialsController < ApplicationController
  def set
    user = User.new(uuid: params[:uuid], device_name: params[:device_name], token: params[:token])

    if user.save
      respond_to do |format|
        format.json { render :status => 202}
      end
    else
      format.json { render :status => 400}
    end
  end
end
