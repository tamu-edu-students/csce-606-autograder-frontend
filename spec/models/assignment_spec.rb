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
          body: { html_url: "https://github.com/#{organization}/#{repository_name}.git" }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        assignment.send(:create_repo_from_template)
        expect(assignment.repository_url).to eq('https://github.com/AutograderFrontend/test-repository.git')
    end
  end

  describe 'clone_repo_to_local' do
    it 'clones a repo to the local filesystem' do
      assignment = Assignment.new(
        assignment_name: 'Test Assignment',
        repository_name: 'test-repository',
        repository_url: 'https://github.com/AutograderFrontend/test-repository.git'
      )

      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('assignments-repos')

      expect(Git).to receive(:clone).with(
        'https://github.com/AutograderFrontend/test-repository.git',
        'assignments-repos/test-repository'
      )

      assignment.send(:clone_repo_to_local)
    end
  end

  describe 'remote_repo_created?' do
    it 'checks if a repo exists on GitHub' do
      repository_name = 'test-repository'
      organization = 'AutograderFrontend'

      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
      allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return(organization)

      stub_request(:get, "https://api.github.com/repos/#{organization}/#{repository_name}").
        with(
          headers: {
            'Accept'=>'application/vnd.github.v3+json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'token test_token',
            'User-Agent'=>'Octokit Ruby Gem 9.1.0'
          }).
        to_return(status: 200, body: '', headers: {})

      assignment = Assignment.new(repository_name: repository_name)
      expect(assignment.send(:remote_repo_created?)).to be true
    end
  end

  describe 'assignment_repo_init' do
    it 'creates a new repo from a template and clones it locally' do
      assignment = Assignment.new(
        assignment_name: 'Test Assignment',
        repository_name: 'test-repository'
      )

      allow(assignment).to receive(:create_repo_from_template)
      allow(assignment).to receive(:clone_repo_to_local)

      assignment.send(:assignment_repo_init)

      expect(assignment).to have_received(:create_repo_from_template)
      expect(assignment).to have_received(:clone_repo_to_local)
    end
  end
end
