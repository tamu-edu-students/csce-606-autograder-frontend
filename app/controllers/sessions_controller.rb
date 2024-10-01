class SessionsController < ApplicationController
    def create
        auth_hash = request.env['omniauth.auth']

        if auth_hash
            if user_belongs_to_organization?(auth_hash)
                user = User.find_or_create_by_auth_hash(auth_hash)
                session[:user_id] = user.id
                redirect_to root_path, notice: "Welcome, #{user.name}!"
            else
                redirect_to root_path, alert: "You must be a member of CSCE-120 organization to access this application."
            end
        else
            redirect_to root_path, alert: "GitHub authentication failed. Please try again."
        end

    end
  
    private
  
    def user_belongs_to_organization?(auth_hash)
      access_token = auth_hash.credentials.token
      client = Octokit::Client.new(access_token: access_token)
      client.organization_member?('AutograderFrontend', auth_hash.info.nickname)
    rescue Octokit::Unauthorized
      # Handle cases where the token might be invalid
      false 
    end
  end