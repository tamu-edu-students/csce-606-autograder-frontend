class Assignment < ActiveRecord::Base
    has_and_belongs_to_many :users
    has_many :tests

    def set_remote_origin(local_repo_path, remote_repo_url)
        # Open the local Git repository
        git = Git.open(local_repo_path)

        # Check if the 'origin' remote already exists
        remote = git.remotes.find { |r| r.name == "origin" }

        if remote
          # If 'origin' exists, update the URL
          remote.url = remote_repo_url
          puts "Updated 'origin' to #{remote_repo_url}"
        else
          # If 'origin' doesn't exist, add it
          git.add_remote("origin", remote_repo_url)
          puts "Added 'origin' with URL #{remote_repo_url}"
        end
    end

    # Push any changes to the remote GitHub repository
    def push_changes_to_github(user, auth_token)
        # Retrieve the base path for all assignments from the environment variable
        base_repo_path = ENV["ASSIGNMENTS_BASE_PATH"] # Base directory for all repositories
        repository_name = self.repository_name # Repository name is a property of the assignment

        # Construct the local path to the specific assignment's repository
        local_repo_path = File.join(base_repo_path, repository_name)

        # Construct the remote GitHub URL using the environment variable and the repository name
        remote_repo_url = "https://#{auth_token}@github.com/#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{repository_name}.git"

        # Set the remote URL for the repository
        # system("git -C #{local_repo_path} remote set-url origin #{remote_repo_url}")

        set_remote_origin(local_repo_path, remote_repo_url)


        # Check if the local repo exists before committing and pushing changes
        if Dir.exist?(local_repo_path)
          commit_local_changes(local_repo_path, user)
          sync_to_github(local_repo_path)
        else
          Rails.logger.error "Local repository not found for #{repository_name}"
        end
    end

    private

    # Commit local changes to the repository
    def commit_local_changes(local_repo_path, user)
        git = Git.open(local_repo_path) # Assuming the `ruby-git` gem is being used
        git.add(all: true) # Add all changes (new, modified, deleted files)
        git.commit("Changes made by #{user.username}") # Use the passed user object to get username
    end

    # Push local changes to the GitHub repository
    def sync_to_github(local_repo_path)
        git = Git.open(local_repo_path)
        git.push("origin", "main") # Push to the remote repository's main branch
    end
end
