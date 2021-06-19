Rails.application.config.middleware.use OmniAuth::Builder do
    provider :mediawiki, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], {:client_options => {:site => 'https://commons.wikimedia.org' }}
end