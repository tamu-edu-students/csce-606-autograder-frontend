class Assignment < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :tests
  
  def generate_tests_file
    FileUtils.mkdir_p(repository_name) unless Dir.exist?(repository_name)

    file_path = "#{repository_name}/.tests"
    File.open(file_path, 'w') do |file|
      tests.each do |test|
        file.puts format_test(test)
      end
    end
  end

  private

  def format_test(test)
    <<~TEST_SPEC
    /*
    @name: #{test.name}
    @points: #{test.points}
    @target: #{test.target}
    @test_type: #{test.test_type}
    @include_files: #{test.include_files}
    */
    <test>
    #{test.test_code}
    </test>
    TEST_SPEC
  end

  # @target is semi-optional (depending on type), but whether it
  # is required or not is checked elsewhere, so it is safe to treat
  # it as optional
  def format_optional_attributes(test)
    optional_attrs = ""
    optional_attributes += "@include_files: #{test.include_files}\n" if test.respond_to?(:include_files)
    optional_attrs += "@target: #{test.target}\n" if test.target.present?
    optional_attrs += "@include: #{test.include_files}\n" if test.include_files.present?
    optional_attrs += "@number: #{test.number}\n" if test.number.present?
    optional_attrs += "@show_output: #{test.show_output}\n" if test.show_output.present?
    optional_attrs += "@skip: #{test.skip}\n" if test.skip.present?
    optional_attrs += "@timeout: #{test.timeout}\n" if test.timeout.present?
    optional_attrs += "@visibility: #{test.visibility}\n" if test.visibility.present?
    optional_attrs
  end

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
