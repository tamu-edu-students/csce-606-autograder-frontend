module TestsHelper
    def update_remote(user, auth_token)
        @assignment.push_changes_to_github(user, auth_token)
    end
    
    def current_user_and_token
        [User.find(session[:user_id]), session[:github_token]]
    end
end
