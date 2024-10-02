class Assignment < ActiveRecord::Base
    after_commit :push_to_remote_repository, on: [:create, :update]

    private

    def push_to_remote_repository
        # Retrieve the current user from the session
        user = User.find(session[:user_id])
        user_name = user.name
        repo_path = self.repo_path   # Path to the local repo (stored dynamically)
        branch = self.branch || 'main'  # Default to 'main' branch if none specified

        if repo_path.present?
        g = Git.open(repo_path)
        
        # Stage, commit, and push the changes, including the user's name in the commit message
        g.add(all: true)
        g.commit("Auto-update: #{self.title} after commit by #{user_name}")
        g.push('origin', branch)
        else
        Rails.logger.warn("Repository path is missing for assignment #{self.id}")
        end
    end
end