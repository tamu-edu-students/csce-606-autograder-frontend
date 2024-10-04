class Assignment < ActiveRecord::Base
  has_many :tests
  validates :repository_name, uniqueness: true
  validates :assignment_name, :repository_name, presence: true
  after_validation :assignment_repo_init, on: :create

  private
  def create_and_add_deploy_key
    # Define paths
    key_dir = "./#{ENV['ASSIGNMENTS_BASE_PATH']}/#{self.repository_name}/secrets/"
    key_path = "./#{ENV['ASSIGNMENTS_BASE_PATH']}/#{self.repository_name}/secrets/deploy_key"

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
      rescue StandardError => e  
        puts "Failed to generate SSH key: #{e.message}"  
    end
    begin
      public_key_content = File.read("#{key_path}.pub")
    rescue StandardError => e
      puts "Failed to read public key: #{e.message}"
      return
    end
    begin
      client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
      client.add_deploy_key("#{ENV["GITHUB_COURSE_ORGANIZATION"]}/#{self.repository_name}", "Gradescope Deploy Key", public_key_content, read_only: true)
    rescue Octokit::Error => e
      puts "Failed to add deploy key to GitHub: #{e.response_body[:message]}"
      return
    end
    puts "Deploy key added successfully for #{self.repository_name}!"
  end
    
  def create_repo_from_template
      client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
      template_repo = ENV["GITHUB_TEMPLATE_REPO_URL"]
      new_repo_name = "#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{repository_name}"
      options = {
          owner: ENV["GITHUB_COURSE_ORGANIZATION"],
          name: assignment_name,
          private: true
      }
      new_repo = client.create_repo_from_template(template_repo, new_repo_name, options)
      puts "New repo created: #{new_repo}"
      self.repository_url = new_repo[:html_url]
  end

  def clone_repo_to_local
      # wait for remote repo to be initialized
      sleep(3)
      Git.clone(self.repository_url, "#{ENV['ASSIGNMENTS_BASE_PATH']}/#{repository_name}")
  end

  def remote_repo_created?
      client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
      repository_path = "#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{repository_name}"
      client.repository?(repository_path)
  end

  def assignment_repo_init
      create_repo_from_template
      clone_repo_to_local
      create_and_add_deploy_key
  end
end
