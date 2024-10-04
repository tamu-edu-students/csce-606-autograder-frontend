Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"],
              scope: "user:email, read:org",
              client_options: {
                site: "https://api.github.com",
                authorize_url: "https://github.com/login/oauth/authorize"
              }
  end
