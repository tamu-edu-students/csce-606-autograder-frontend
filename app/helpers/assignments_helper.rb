require 'octokit'

module AssignmentsHelper
    def create_and_add_deploy_key(repo_name)
        # Define paths
        key_path = './deploy_key'
        secret_key_path = './secrets/deploy_key'
        # Step 1: Generate SSH key
        begin
          Open3.capture3("ssh-keygen -t ed25519 -C \"gradescope\" -f #{key_path} -N ''")
        rescue StandardError => e
          puts "Failed to generate SSH key: #{e.message}"
          return
        end
        begin
          FileUtils.mv(key_path, secret_key_path)
        rescue StandardError => e
          puts "Failed to move deploy key: #{e.message}"
          return
        end
        begin
          public_key_content = File.read("#{key_path}.pub")
        rescue StandardError => e
          puts "Failed to read public key: #{e.message}"
          return
        end
        begin
          client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
          client.add_deploy_key(repo_name, "Gradescope Deploy Key", public_key_content, read_only: false)
        rescue Octokit::Error => e
          puts "Failed to add deploy key to GitHub: #{e.response_body[:message]}"
          return
        end
        puts "Deploy key added successfully for #{repo_name}!"
    end
    
    def create_repo_from_template(assignment)
        client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
        template_repo = ENV['GITHUB_TEMPLATE_REPO_URL']
        new_repo_name = assignment.repository_name.downcase.gsub(' ', '-')
        options = {
            owner: ENV['GITHUB_COURSE_ORGANIZATION'],
            name: assignment.assignment_name,
            private: true,
        }
        new_repo = client.create_repo_from_template(template_repo, new_repo_name, options)
        assignment.update(repository_url: new_repo[:html_url])
    end
end
