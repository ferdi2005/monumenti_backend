class GetUserInfoWorker
  include Sidekiq::Worker

  def perform(user)
    return unless user.authorized
    
    if user.testuser
      oauth_consumer = $test_oauth_consumer
    else
      oauth_consumer = $oauth_consumer
    end

    @token = OAuth::AccessToken.new(oauth_consumer)
    @token.secret = user.authinfo["secret"]
    @token.token = user.authinfo["token"]

    username = JSON.parse(@token.get("/w/api.php?action=query&meta=userinfo&uiprop=*&format=json").body)["query"]["userinfo"]["name"]

    user.update!(username: username)
  end
end
