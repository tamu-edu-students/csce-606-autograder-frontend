require 'octokit'

module AssignmentsHelper
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
