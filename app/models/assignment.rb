class Assignment < ActiveRecord::Base
    validates :repository_name, uniqueness: true
    validates :assignment_name, :repository_name, presence: true    
    after_validation :assignment_repo_init, on: :create

    private
    def create_repo_from_template
        client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
        template_repo = ENV['GITHUB_TEMPLATE_REPO_URL']
        new_repo_name = repository_name.downcase.gsub(' ', '-')
        options = {
            owner: ENV['GITHUB_COURSE_ORGANIZATION'],
            name: assignment_name,
            private: true,
        }
        new_repo = client.create_repo_from_template(template_repo, new_repo_name, options)
        self.repository_url = new_repo[:html_url]       
    end

    def clone_repo_to_local
        # wait for remote repo to be initialized
        sleep(3)
        Git.clone(self.repository_url, "#{ENV['ASSIGNMENTS_BASE_PATH']}/#{repository_name}")
    end

    def remote_repo_created?
        client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
        repository_path = "#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{repository_name}"
        client.repository?(repository_path)
    end

    def assignment_repo_init
        create_repo_from_template
        clone_repo_to_local
    end
end