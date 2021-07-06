require 'net/http/post/multipart'
class UploadWorker
  include Sidekiq::Worker
  include AuthenticationHelper

  def perform(id)
    return unless (photo = Photo.find_by(id: id))

    unless photo.user.authorized && photo.user.ready && photo.confirmed
      UplaodWorker.perform_in(1.hour, photo)
      return
    end

    begin
      # Se l'utente è un testuser, usa la wiki di test
      if photo.user.testuser
        oauth_consumer = $test_oauth_consumer
      else
        oauth_consumer = $oauth_consumer
      end

      @token = OAuth::AccessToken.new(oauth_consumer)
      @token.secret = photo.user.authinfo["secret"]
      @token.token = photo.user.authinfo["token"]
      
      csrf = JSON.parse(@token.get("/w/api.php?action=query&meta=tokens&format=json").body)["query"]["tokens"]["csrftoken"]

      # Recupero informazioni sul monumento ritratto
      info = HTTParty.get("https://cerca.wikilovesmonuments.it/show_by_wikidata.json?item=#{photo.monument}").to_h

      wlm_categories = []
      # Aggiungo le categorie di WLM
      info["uploadurl"].split("&").find { |a| a.start_with?("categories=") }.gsub("categories=", "").split("%7C").each { |c| wlm_categories.push("[[Category:#{c.gsub('+', ' ').gsub('%28', '(').gsub('%29', ')')}]]") }
      
      categories = []
      # Aggiungo le categorie non wlm
      info["nonwlmuploadurl"].split("&").find { |a| a.start_with?("categories=") }.gsub("categories=", "").split("%7C").each { |c| categories.push("[[Category:#{c.gsub('+', ' ').gsub('%28', '(').gsub('%29', ')')}]]") }

      # Testo della pagina su Commons
      if photo.created_at.month == 9 # Fotografia partecipante a Wiki Loves Monuments
        text = "== {{int:filedesc}} ==
{{Information
|description={{it|1=#{photo.description}}}{{Monumento italiano|#{photo.monument}|anno=#{photo.date.year}}}
|date=#{photo.date.strftime}
|source={{own}}
|author=[[User:#{photo.user.username}|#{photo.user.username}]]
}}

== {{int:license-header}} ==
{{self|cc-by-sa-4.0}}
        
{{Wiki Loves Monuments #{photo.date.year}|it}}

#{wlm_categories.join("\n")}"
      else
        text = "== {{int:filedesc}} ==
{{Information
|description={{it|1=#{photo.description}}}
|date=#{photo.date.strftime}
|source={{own}}
|author=[[User:#{photo.user.username}|#{photo.user.username}]]
}}

== {{int:license-header}} ==
{{self|cc-by-sa-4.0}}

#{categories.join("\n")}"
      end

      req = Net::HTTP::Get.new("/w/api.php?action=query&meta=userinfo&uiprop=groups|rights&format=json")
      req = Net::HTTP::Post::Multipart.new("/w/api.php", action: :upload, file: UploadIO.new(ActiveStorage::Blob.service.send(:path_for, photo.file.blob.key), photo.file.blob.content_type, photo.file.blob.filename.to_s), filename: photo.title, text: text, async: true, ignorewarnings: true, token: csrf, format: :json)
      # req['Authorization'] = @token.sign!(req)
      req['Authorization'] = oauth_consumer.sign!(req, @token)
      meq = Net::HTTP.new(@token.consumer.uri.host, @token.consumer.uri.port) 
      meq.use_ssl = true
      res = meq.start do |http|
        http.request(req)
      end

      result = JSON.parse(res.body)

      if result["upload"]["result"] == "Success"
        photo.update!(canonicaltitle: result["upload"]["imageinfo"]["canonicaltitle"], descriptionurl: result["upload"]["imageinfo"]["descriptionurl"], url: result["upload"]["imageinfo"]["url"], sha1: result["upload"]["imageinfo"]["sha1"], uploaded: true)
      else
        photo.update!(uploaded: false)
      end
    rescue
      photo.update!(uploaded: false)
    end
  end
end
