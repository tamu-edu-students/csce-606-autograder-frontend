class Assignment < ActiveRecord::Base
  def create_and_add_deploy_key
    # Define paths
    key_path = "./#{ENV['ASSIGNMENTS_BASE_PATH']}/#{self.repository_name}/secrets/deploy_key"
    # Step 1: Generate SSH key
    begin  
      stdout, stderr, status = Open3.capture3("ssh-keygen", "-t", "ed25519", "-C", "gradescope", "-f", key_path)  
    
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
      client.add_deploy_key(self.repository_name, "Gradescope Deploy Key", public_key_content, read_only: true)
    rescue Octokit::Error => e
      puts "Failed to add deploy key to GitHub: #{e.response_body[:message]}"
      return
    end
    puts "Deploy key added successfully for #{self.repository_name}!"
  end
end