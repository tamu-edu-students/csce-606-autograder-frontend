class Assignment < ActiveRecord::Base
  has_many :tests
  validates :repository_name, uniqueness: { message: "must be unique. This repository name is already taken." }
  validates :assignment_name, :repository_name, presence: true
  after_validation :assignment_repo_init, on: :create

  def repository_identifier
    
    File.join(ENV["GITHUB_COURSE_ORGANIZATION"], self.repository_name)
  end

  def local_repository_path
    
    
    File.join(ENV["ASSIGNMENTS_BASE_PATH"], self.repository_name)
  end

  private
  def create_and_add_deploy_key(repository_name, organization, dest_path, autograder_core = false)
    # Define paths
    key_prefix = autograder_core ? "autograder_core_" : ""
    key_dir = File.join(dest_path, "secrets")
    key_path = File.join(dest_path, "secrets", "#{key_prefix}deploy_key")

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
      client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
      client.add_deploy_key("#{organization}/#{repository_name}", "Gradescope Deploy Key", public_key_content, read_only: true)
    rescue Octokit::Error => e
      puts "Failed to add deploy key to GitHub: #{e.response_body[:message]}"
      return
    end
    puts "Deploy key added successfully for #{repository_name}!"
  end

  def create_repo_from_template
    template_repo = ENV["GITHUB_TEMPLATE_REPO_URL"]
    new_repo_name = "#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{repository_name}"
    options = {
        owner: ENV["GITHUB_COURSE_ORGANIZATION"],
        name: assignment_name,
        private: true
    }
    begin
      client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
      new_repo = client.create_repo_from_template(template_repo, new_repo_name, options)
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

  def remote_repo_created?
    begin
      client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
      client.repository?(self.repository_identifier)
    rescue Octokit::Error => e
      puts "Failed to check whether remote repo has been created: #{e.response_body[:message]}"
      nil
    end
  end

  def assignment_repo_init
      create_repo_from_template
      clone_repo_to_local
      create_and_add_deploy_key(
        self.repository_name,
        ENV["GITHUB_COURSE_ORGANIZATION"],
        self.local_repository_path,
        false
      )
      create_and_add_deploy_key(
        self.repository_name,
        ENV["GITHUB_COURSE_ORGANIZATION"],
        self.local_repository_path,
        true
      )
  end
end
