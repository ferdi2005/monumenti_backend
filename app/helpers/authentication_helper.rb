module AuthenticationHelper
    $oauth_consumer = OAuth::Consumer.new(ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"], :site => "https://commons.wikimedia.org", :request_token_path => "/w/index.php?title=Special:OAuth/initiate", :authorize_path => "/wiki/Special:OAuth/authorize", :access_token_path => "/wiki/Special:OAuth/token",)

    $test_oauth_consumer = OAuth::Consumer.new(ENV["TEST_CONSUMER_KEY"], ENV["TEST_CONSUMER_SECRET"], :site => "https://app-test.ferdinando.me", :request_token_path => "/w/index.php?title=Special:OAuth/initiate", :authorize_path => "/wiki/Special:OAuth/authorize", :access_token_path => "/wiki/Special:OAuth/token",)
    # Sempre mettere lo / davanti
end
