class Assignment < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :tests
  validates :repository_name, uniqueness: { message: "must be unique. This repository name is already taken." }
  validates :assignment_name, :repository_name, presence: true

  def repository_identifier
    File.join(ENV["GITHUB_COURSE_ORGANIZATION"], self.repository_name)
  end

  def local_repository_path
    File.join(ENV["ASSIGNMENTS_BASE_PATH"], self.repository_name)
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

  def assignment_repo_init(github_token)
    create_repo_from_template(github_token)
    clone_repo_to_local
    create_and_add_deploy_key(
      github_token,
      self.repository_name,
      ENV["GITHUB_COURSE_ORGANIZATION"],
      self.local_repository_path,
      false
    )
    create_and_add_deploy_key(
      github_token,
      self.repository_name,
      ENV["GITHUB_COURSE_ORGANIZATION"],
      self.local_repository_path,
      true
    )
  end

  def generate_tests_file
    FileUtils.mkdir_p(repository_name) unless Dir.exist?(repository_name)

    file_path = File.join(local_repository_path, "tests", "c++", "code.tests")
    File.open(file_path, "w") do |file|
      tests.each do |test|
        file.puts format_test(test)
      end
    end
  end

  private

  # Commit local changes to the repository
  def commit_local_changes(local_repo_path, user)
      git = Git.open(local_repo_path) # Assuming the `ruby-git` gem is being used
      git.add(all: true) # Add all changes (new, modified, deleted files)
      git.commit("Changes made by #{user.name}") # Use the passed user object to get username
  end

  # Push local changes to the GitHub repository
  def sync_to_github(local_repo_path)
      git = Git.open(local_repo_path)
      git.push("origin", "main") # Push to the remote repository's main branch
  end

  def create_and_add_deploy_key(github_token, repository_name, organization, dest_path, autograder_core = false)
    # Define paths
    key_prefix = autograder_core ? "autograder_core_" : ""
    key_dir = File.join(dest_path, "secrets")
    key_path = File.join(dest_path, "secrets", "#{key_prefix}deploy_key")

    puts "Creating deploy key under #{key_path}"
    FileUtils.mkdir_p(key_dir)
    # Step 1: Generate SSH key
    begin
      stdout, stderr, status = Open3.capture3("ssh-keygen", "-t", "ed25519", "-C", "gradescope", "-f", key_path, "-N", "")

      if status.success?
        puts "Key generated successfully."
      else
        puts "Error generating key: #{stderr.strip}"
      end
    rescue Errno::ENOENT => e
      puts "Command not found: #{e.message}"
      return
    rescue StandardError => e
      puts "Failed to generate SSH key: #{e.message}"
      return
    end
    begin
      public_key_content = File.read("#{key_path}.pub")
    rescue StandardError => e
      puts "Failed to read public key: #{e.message}"
      return
    end
    begin
      client = Octokit::Client.new(access_token: github_token)
      client.add_deploy_key("#{organization}/#{repository_name}", "Gradescope Deploy Key", public_key_content, read_only: true)
    rescue Octokit::Error => e
      puts "Failed to add deploy key to GitHub: #{e.response_body[:message]}"
      return
    end
    puts "Deploy key added successfully for #{repository_name}!"
  end

  def create_repo_from_template(github_token)
    template_repo = ENV["GITHUB_TEMPLATE_REPO_URL"]
    options = {
        owner: ENV["GITHUB_COURSE_ORGANIZATION"],
        name: assignment_name,
        private: true
    }
    begin
      client = Octokit::Client.new(access_token: github_token)
      new_repo = client.create_repo_from_template(template_repo, self.repository_name, options)
    rescue Octokit::Error => e
      puts "Failed to clone repo from assignment template: #{e.response_body[:message]}"
      return
    end
    self.repository_url = new_repo[:html_url]
  end

  def clone_repo_to_local
      # wait for remote repo to be initialized
      sleep(3)
      begin
        Git.clone(self.repository_url, self.local_repository_path)
      rescue Git::Error => e
        puts "An error occurred: #{e.message}"
        nil
      end
  end

  def remote_repo_created?(github_token)
    begin
      client = Octokit::Client.new(access_token: github_token)
      client.repository?(self.repository_identifier)
    rescue Octokit::Error => e
      puts "Failed to check whether remote repo has been created: #{e.response_body[:message]}"
      nil
    end
  end

  def format_test(test)
    <<~TEST_SPEC
    /*
    @name: #{test.name}
    @points: #{test.points}
    @test_type: #{test.test_type}
    */
    <test>
    #{test.actual_test}
    </test>
    TEST_SPEC
  end

  def format_optional_attributes(test)
    optional_attrs = ""
    optional_attrs += "@target: #{test.target}\n" if test.target.present?
    optional_attrs += "@include: #{test.include_files}\n" if test.include_files.present?
    optional_attrs += "@number: #{test.number}\n" if test.number.present?
    optional_attrs += "@show_output: #{test.show_output}\n" if test.show_output.present?
    optional_attrs += "@skip: #{test.skip}\n" if test.skip.present?
    optional_attrs += "@timeout: #{test.timeout}\n" if test.timeout.present?
    optional_attrs += "@visibility: #{test.visibility}\n" if test.visibility.present?
    optional_attrs
  end
end
