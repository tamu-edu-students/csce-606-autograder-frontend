require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Assignment, type: :model do
  describe 'create_repo_from_template' do
    it 'creates a new repo from a template' do
      assignment_name = 'Test Assignment'
      repository_name = 'test-repository'
      organization = 'AutograderFrontend'
      template_repo = 'philipritchey/autograded-assignment-template'

      allow(ENV).to receive(:[]).and_return(nil)

      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
      allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return(template_repo)
      allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return(organization)

      stub_request(:post, "https://api.github.com/repos/philipritchey/autograded-assignment-template/generate").
         with(
          body: { owner: organization, name: "#{organization}/#{repository_name}", private: true }.to_json,
           headers: {
          'Accept'=>'application/vnd.github.v3+json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'token test_token',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Octokit Ruby Gem 9.1.0'
           }).
         to_return(
          status: 201,
          body: { html_url: "https://github.com/#{organization}/#{repository_name}" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        assignment.send(:create_repo_from_template)
        expect(assignment.repository_url).to eq('https://github.com/AutograderFrontend/test-repository')
    end
  end
end
