Rails.application.config.middleware.use OmniAuth::Builder do
    # provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], 
    provider :github, 'Ov23livChGPH5MsuW612', '477395f731734462a4da25d11affd2bb15a4cee0', 
              scope: 'user:email, read:org',
              client_options: {
                site: 'https://api.github.com',
                authorize_url: 'https://github.com/login/oauth/authorize'
              }
  end