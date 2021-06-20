class PhotosController < ApplicationController
  def upload
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      Date.today.month == 9 ? wlm = true : wlm = false
      photo = Photo.create(user: user, wlm: wlm, monument: params[:monument])
      if !params[:file].blank? && photo.file.attach(params[:file])
        respond_to { |format| format.json {render json: {"id": photo.id}}}
      else
        respond_to { |format| format.json {render json: {"error": "Photo upload not succeded."}}}
      end
    else
      respond_to { |format| format.json {render json: {"error": "User not found."}}}
    end
  end

  def title
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      errors = []
      success = []
      JSON.parse(params[:photos]).each do |key, value|
        if (photo = Photo.find_by(id: key, user: user))
          photo.update!(title: value[0], description: value[1], date: value[2], confirmed: true)
          success.push(photo[0])
          # TODO: Dare il via al job di caricamento effettivo
        else
          errors.push(photo[0])
        end
      end
      respond_to { |format| format.json {render json: {"errors":errors, "success": success }}}
    else
      respond_to { |format| format.json {render json: {"error": "User not found."}}}
    end
  end

  def cancel
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
     
      JSON.parse(params[:ids]).each do |id|
        if (photo = Photo.find_by(id: id, user: user))
          photo.destroy!
        end
      end
    respond_to { |format| format.json {render json: {"processed": true}}}

    else
      respond_to { |format| format.json {render json: {"error": "User not found."}}}
    end
  end
end
