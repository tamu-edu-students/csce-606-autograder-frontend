class Assignment < ActiveRecord::Base
  has_many :permissions, dependent: :destroy
  has_many :users, through: :permissions
  has_many :test_groupings, dependent: :destroy
  has_many :tests, through: :test_groupings, dependent: :destroy
  has_many :tests, dependent: :destroy # TODO: remove this association once TestGrouping CRUD is implemented

  before_validation :normalize_repo_name

  validates :repository_name, uniqueness: { message: "must be unique. This repository name is already taken." }
  validates :assignment_name, :repository_name, presence: true

  after_create :ensure_default_test_grouping

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

      # Set the remote URL for the repository
      # system("git -C #{local_repo_path} remote set-url origin #{remote_repo_url}")

      # Clones remote repository to local
      clone_repo_to_local(auth_token)

      set_remote_origin(local_repo_path, authenticated_url(auth_token))


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
    clone_repo_to_local(github_token)
    create_and_add_deploy_key(
      github_token,
      self.repository_name,
      ENV["GITHUB_COURSE_ORGANIZATION"],
      self.local_repository_path,
      false
    )
    # TODO: This should add the key to the auto-grader core repo
    create_and_add_deploy_key(
      github_token,
      self.repository_name,
      ENV["GITHUB_COURSE_ORGANIZATION"],
      self.local_repository_path,
      true
    )
  end

  def generate_tests_file
    directory_path = File.join(local_repository_path, "tests", "c++")
    FileUtils.mkdir_p(directory_path)

    file_path = File.join(directory_path, "code.tests")
    File.open(file_path, File::WRONLY | File::CREAT | File::TRUNC) do |file|
      tests.each do |test|
        file.puts format_test(test)
      end
    end
  end
  # To make the Github Repo Link
  def github_repository_url
    organization = ENV["GITHUB_COURSE_ORGANIZATION"]
    "https://github.com/#{organization}/#{repository_name}"
  end

  def fetch_directory_structure(github_token)
    client = Octokit::Client.new(access_token: github_token)
    organization = ENV["GITHUB_COURSE_ORGANIZATION"]
    repo_path = "#{organization}/#{repository_name}"
    begin
      contents = client.contents(repo_path, path: "tests")
      build_file_tree(contents, client, repo_path)
    rescue Octokit::Error => e
      Rails.logger.error "GitHub API Error: #{e.message}"
      []
    end
  end

  def upload_file_to_repo(file, path, github_token)
    return false unless file.respond_to?(:read) && path.present?
    client = Octokit::Client.new(access_token: github_token)
    repo = "#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{repository_name}"
    file_content = file.read

    testsPath = "tests"
    full_path = "#{testsPath}/#{path}/#{file.original_filename}"

    begin
      client.create_contents(repo, full_path, "Upload #{file.original_filename}", file_content)
      true
    rescue Octokit::Error => e
      Rails.logger.error "GitHub API Error: #{e.message}"
      false
    end
  end

  private

  def build_file_tree(contents, client, repo_path)
    contents.map do |item|
      if item[:type] == "dir"
        {
          name: item[:name],
          type: "directory",
          children: build_file_tree(client.contents(repo_path, path: item[:path]), client, repo_path)
        }
      else
        {
          name: item[:name],
          type: "file"
        }
      end
    end
  end

  def authenticated_url(github_token)
    "https://#{github_token}@#{self.repository_url[8..]}"
  end

  def ensure_default_test_grouping
    test_groupings.find_or_create_by!(name: "Miscellaneous Tests")
  end

  # Commit local changes to the repository
  def commit_local_changes(local_repo_path, user)
      begin
        git = Git.open(local_repo_path) # Assuming the `ruby-git` gem is being used
        git.config("user.name", user.name) # Set the Git user name
        git.config("user.email", user.email) # Set the Git user email
        git.add(all: true) # Add all changes (new, modified, deleted files)
        git.commit("Changes made by #{user.name}") # Use the passed user object to get username
      rescue Git::Error => e
        puts "Error in commiting: #{e.message}"
      end
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
    # wait for remote repo to be initialized
    sleep(3)
    self.repository_url = new_repo[:html_url]
    puts "Repo created successfully at #{self.repository_url}"
    self.save
  end

  def clone_repo_to_local(github_token)
      begin
        if Dir.exist?(self.local_repository_path) && !Dir.exist?("#{self.local_repository_path}/.git")
          FileUtils.rm_rf(self.local_repository_path)
        end
        if !Dir.exist?(self.local_repository_path)
          Git.clone(authenticated_url(github_token), self.local_repository_path)
        end
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
    test = "/*\n" +
    "@name: #{test.name}\n" +
    "@points: #{test.points.to_f}\n" +
    "@test_type: #{test.test_type}\n" +
    "#{format_optional_attributes(test)}" +
    "*/\n" +
    "<test>\n" +
    "#{test.get_test_block_string}\n" +
    "</test>\n\n"
    test.gsub("\r\n", "\n")
  end

  def format_optional_attributes(test)
    optional_attrs = ""
    optional_attrs += "@target: #{test.target}\n" if test.target.present?
    includes = if test.include.is_a?(String) && test.include.start_with?("[")
      JSON.parse(test.include)
    else
      test.include
    end
    # Convert array or string to space-separated format
    include_list = includes.is_a?(Array) ? includes.join(" ") : includes
    optional_attrs += "@include: #{include_list}\n"
    optional_attrs += "@number: #{test.position}\n" if test.position.present?
    optional_attrs += "@show_output: #{test.show_output}\n" if test.show_output.present?
    optional_attrs += "@skip: #{test.skip}\n" if test.skip.present?
    optional_attrs += "@timeout: #{test.timeout}\n" if test.timeout.present?
    optional_attrs += "@visibility: #{test.visibility}\n" if test.visibility == "hidden"
    optional_attrs
  end

  def normalize_repo_name
    if self.repository_name.present?
      repository_name = self.repository_name.downcase

      # Replace spaces/underscores with hyphens
      repository_name = repository_name.gsub(/[ _]/, "-")

      # Remove any non-alphanumeric/hyphen chars
      repository_name = repository_name.gsub(/[^a-z0-9\-]/, "")

      # Remove leading/trailing hyphens
      repository_name = repository_name.gsub(/^-+|-+$/, "")

      self.repository_name = repository_name
    end
  end
end
