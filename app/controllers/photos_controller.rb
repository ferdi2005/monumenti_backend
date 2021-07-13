class PhotosController < ApplicationController
  def upload
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      Date.today.month == 9 ? wlm = true : wlm = false
      photo = Photo.create(user: user, wlm: wlm, monument: params[:monument])
      if !params[:file].blank? && photo.file.attach(params[:file])
        info = HTTParty.get("https://cerca.wikilovesmonuments.it/show_by_wikidata.json?item=#{photo.monument}").to_h

        respond_to { |format| format.json {render json: {"id": photo.id, city: info["city"], label: info["itemlabel"], timestamp: photo.created_at.strftime("%Y%m%d%H%M"), today: Date.today.strftime("%d/%m/%Y")}}}
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
      # Array delle foto caricate e da processare 
      success_ids = []
      JSON.parse(params[:photos]).each do |key, value|
        if (photo = Photo.find_by(id: key, user: user))
          unless value[0].blank? || value[1].blank? || value[2].blank? || !value[2].match?(/\d{2}\/\d{2}\/\d{4}/)
            photo.update!(title: value[0], description: value[1], date: value[2], confirmed: true)
            success.push(photo[0])
            # Prepara per l'upload
            success_ids.push(photo.id)
          else
            photo.update!(uploaded: false)
            errors.push(photo[0])
          end
        else
          errors.push(photo[0])
        end
      end
      respond_to { |format| format.json {render json: {"errors":errors, "success": success }}}
      # Processa le fotografie
      UploadWorker.perform_async(success_ids, user.id)
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

  def index
    if (user = User.find_by(uuid: params[:uuid], token: params[:token]))
      if params[:order] == "title"
        response = user.photos.sort_by do |p|
          if p.title != nil
            p.title
          else
            "nil"
          end
        end
        response = response.as_json.map{|p| p = p.merge({serverurl: Photo.find(p["id"]).serverurl, item: Photo.find(p["id"]).monument})}
      else
        response = user.photos.sort_by {|p| p.created_at}.as_json.map{|p| p = p.merge(serverurl: Photo.find(p["id"]).serverurl)}
      end

      respond_to { |format| format.json {render json: response } }
    else
      respond_to { |format| format.json {render status: 404, json: {"error": "User not found."}}}
    end
  end
end
