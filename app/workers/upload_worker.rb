require 'net/http/post/multipart'
class UploadWorker
  include Sidekiq::Worker
  include AuthenticationHelper

  def perform(ids, user_id)
    # Criteri di esclusione (il job neanche dovrebbe partire)
    return unless (user = User.find_by(id: user_id))

    return unless user.authorized && user.ready

    # Se l'utente è un testuser, usa la wiki di test
    if user.testuser
      oauth_consumer = $test_oauth_consumer
    else
      oauth_consumer = $oauth_consumer
    end

    @token = OAuth::AccessToken.new(oauth_consumer)
    @token.secret = user.authinfo["secret"]
    @token.token = user.authinfo["token"]
    
    ids.each do |id|
      begin
        # Criteri di esclusione (il job non dovrebbe neanche partire)
        next unless (photo = Photo.find_by(id: id))

        next unless photo.confirmed

        next if photo.uploaded

        title = "File:#{photo.title}.#{photo.file.blob.filename.extension}" # Genero titolo della foto
        
        check_existence = HTTParty.get("https://commons.wikimedia.org/w/api.php", query: {action: :query, titles: title, format: :json}).to_h

        if check_existence.try(:[], "query").try(:[], "pages").try(:[], "-1").nil?
          photo.update!(uploaded: false, errorinfo: "Un'immagine con lo stesso titolo è già presente.")
          next
        end

        csrf_request = JSON.parse(@token.get("/w/api.php?action=query&meta=tokens&format=json").body)
        csrf = csrf_request.try(:[], "query").try(:[], "tokens").try(:[], "csrftoken")

        if csrf == nil 
          if csrf_request.try(:[], "error").try(:[], "code") == "mwoauth-invalid-authorization"
            photo.update!(uploaded: false, errorinfo: csrf_request.try(:[], "error").try(:[], "info"))
            next
          else
            photo.update!(uploaded: false, errorinfo: "MediaWiki did not return a valid CSRF token. Please check your login settings.")
            next
          end
        end

        # Recupero informazioni sul monumento ritratto
        info = HTTParty.get("https://cerca.wikilovesmonuments.it/show_by_wikidata.json?item=#{photo.monument}").to_h

        wlm_categories = []
        # Aggiungo le categorie di WLM
        info["uploadurl"].split("&").find { |a| a.start_with?("categories=") }.gsub("categories=", "").split("%7C").each { |c| wlm_categories.push("[[Category:#{c.gsub('+', ' ').gsub('%28', '(').gsub('%29', ')')}]]") }
        
        categories = []
        # Aggiungo le categorie non wlm
        info["nonwlmuploadurl"].split("&").find { |a| a.start_with?("categories=") }.gsub("categories=", "").split("%7C").each { |c| categories.push("[[Category:#{c.gsub('+', ' ').gsub('%28', '(').gsub('%29', ')')}]]") }

        # Testo della pagina su Commons
        if photo.created_at.month == 9 || user.testuser # Fotografia partecipante a Wiki Loves Monuments o utente testuser
          text = "== {{int:filedesc}} ==
{{Information
|description={{it|1=#{photo.description}}}{{Monumento italiano|#{info["wlmid"]}|anno=#{photo.date.year}}}{{Load via app WLM.it|year=#{photo.date.year}}}
|date=#{photo.date.strftime}
|source={{own}}
|author=[[User:#{user.username}|#{user.username}]]
}}

== {{int:license-header}} ==
{{self|cc-by-sa-4.0}}

{{Wiki Loves Monuments #{photo.date.year}|it}}

#{wlm_categories.join("\n")}"
        else
          text = "== {{int:filedesc}} ==
{{Information
|description={{it|1=#{photo.description}}}{{Load via app WLM.it|year=#{photo.date.year}}}
|date=#{photo.date.strftime}
|source={{own}}
|author=[[User:#{user.username}|#{user.username}]]
}}

== {{int:license-header}} ==
{{self|cc-by-sa-4.0}}

#{categories.join("\n")}"
        end

        # Faccio la richiesta per il caricamento della foto
        req = Net::HTTP::Post::Multipart.new("/w/api.php", action: :upload, file: UploadIO.new(ActiveStorage::Blob.service.send(:path_for, photo.file.blob.key), photo.file.blob.content_type, photo.file.blob.filename.to_s), filename: title, text: text, ignorewarnings: true, token: csrf, format: :json)
        # req['Authorization'] = @token.sign!(req)
        req['Authorization'] = oauth_consumer.sign!(req, @token)
        meq = Net::HTTP.new(@token.consumer.uri.host, @token.consumer.uri.port)
        meq.use_ssl = true
        meq.read_timeout = 18000 
        res = meq.start do |http|
          http.request(req)
        end

        result = JSON.parse(res.body)

        if result.try(:[], "upload").try(:[], "result") == "Success"
          photo.update!(canonicaltitle: result["upload"]["imageinfo"]["canonicaltitle"], descriptionurl: result["upload"]["imageinfo"]["descriptionurl"], url: result["upload"]["imageinfo"]["url"], sha1: result["upload"]["imageinfo"]["sha1"], uploaded: true)
        else
          photo.update!(uploaded: false)
          if (error = result["error"].try(:[], "info"))
            photo.update!(errorinfo: error)
          end
        end
      rescue => e
        photo.update!(uploaded: false, errorinfo: e)
      end
    end
  end
end
