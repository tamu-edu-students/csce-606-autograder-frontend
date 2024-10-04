require 'rails_helper'
require 'webmock/rspec'
require 'open3'
require 'octokit'

RSpec.describe Assignment, type: :model do
  let(:assignment) { Assignment.new(repository_name: 'test-repo', assignment_name: 'Test Assignment') }

  before do
    # Set the environment variable for the test
    ENV['ASSIGNMENTS_BASE_PATH'] = 'assignments_path'
  end

  after do
    # Clean up the environment variable after the test
    ENV.delete('ASSIGNMENTS_BASE_PATH')
  end

  describe '#create_and_add_deploy_key' do
    let(:key_path) { "./#{ENV['ASSIGNMENTS_BASE_PATH']}/#{assignment.repository_name}/secrets/deploy_key" }

    before do
      allow(Open3).to receive(:capture3).and_return([ 'Key generated successfully', '', double(success?: true) ])
      allow(File).to receive(:read).with("#{key_path}.pub").and_return('mock_public_key_content')
      allow(Octokit::Client).to receive(:new).and_return(double('OctokitClient', add_deploy_key: true))
    end

    it 'generates an SSH key' do
      expect(Open3).to receive(:capture3).with('ssh-keygen', '-t', 'ed25519', '-C', 'gradescope', '-f', key_path)
      assignment.send(:create_and_add_deploy_key)
    end

    it 'reads the generated public key' do
      expect(File).to receive(:read).with("#{key_path}.pub")
      assignment.send(:create_and_add_deploy_key)
    end

    it 'adds a deploy key to the GitHub repository' do
      client = double('OctokitClient')
      allow(Octokit::Client).to receive(:new).and_return(client)
      expect(client).to receive(:add_deploy_key).with(assignment.repository_name, 'Gradescope Deploy Key', 'mock_public_key_content', read_only: true)
      assignment.send(:create_and_add_deploy_key)
    end

    context 'when SSH key generation fails' do
      before do
        allow(Open3).to receive(:capture3).and_return([ '', 'Error generating key', double(success?: false) ])
      end

      it 'logs an error message' do
        expect { assignment.send(:create_and_add_deploy_key) }.to output(/Error generating key/).to_stdout
      end
    end

    context 'when reading the public key fails' do
      before do
        allow(File).to receive(:read).and_raise(StandardError.new('File read error'))
      end

      it 'logs an error message' do
        expect { assignment.send(:create_and_add_deploy_key) }.to output(/Failed to read public key: File read error/).to_stdout
      end
    end

    context 'when adding the deploy key to GitHub fails' do
      before do
        client = double('OctokitClient')
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:add_deploy_key).and_raise(Octokit::Error.new(
            { status: 422,
            body: { message: "GitHub API error" },
            headers: {} }))
        end

      it 'logs an error message' do
        expect { assignment.send(:create_and_add_deploy_key) }.to output(/Failed to add deploy key to GitHub: GitHub API error/).to_stdout
      end
    end
  end
  describe 'create_repo_from_template' do
    let(:assignment_name) { 'Test Assignment' }
    let(:repository_name) { 'test-repository' }
    let(:organization) { 'AutograderFrontend' }
    let(:template_repo) { 'philipritchey/autograded-assignment-template' }

    before do
      allow(ENV).to receive(:[]).and_return(nil)

      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
      allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return(template_repo)
      allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return(organization)

      stub_request(:post, "https://api.github.com/repos/philipritchey/autograded-assignment-template/generate")
      .with(
        body: { owner: organization, name: "#{organization}/#{repository_name}", private: true }.to_json,
          headers: {
          'Accept'=>'application/vnd.github.v3+json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'token test_token',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Octokit Ruby Gem 9.1.0'
          }
      )
      .to_return(
      status: 201,
      body: { html_url: "https://github.com/#{organization}/#{repository_name}.git" }.to_json,
      headers: { 'Content-Type' => 'application/json' }
      )
    end
    context 'when repo creation is successful' do
      it 'creates a new repo from a template' do
        expect(assignment.repository_url).to eq('https://github.com/AutograderFrontend/test-repository.git')
      end
    end

    context 'when repo creation is unsuccessful' do
      let(:client) { instance_double(Octokit::Client) }

      before do
        allow(client).to receive(:create_repo_from_template).and_raise(Octokit::Error.new({ status: 422, body: { message: 'GitHub API Error' }, headers: {} }))
      end

      it 'raises a GitHub API Error' do
        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        assignment.send(:create_repo_from_template)
        expect { assignment.create_repo_from_template }.to output(/Failed to clone repo from assignment template: GitHub API Error/).to_stdout
      end
    end
  end

  describe 'remote_repo_created?' do
    it 'checks if a repo exists on GitHub' do
      repository_name = 'test-repository'
      organization = 'AutograderFrontend'

      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
      allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return(organization)

      stub_request(:get, "https://api.github.com/repos/#{organization}/#{repository_name}")
        .with(
          headers: {
            'Accept'=>'application/vnd.github.v3+json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'token test_token',
            'User-Agent'=>'Octokit Ruby Gem 9.1.0'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      assignment = Assignment.new(repository_name: repository_name)
      expect(assignment.send(:remote_repo_created?)).to be true
    end

    it 'returns false if the repo does not exist on GitHub' do
      repository_name = 'test-repository'
      organization = 'AutograderFrontend'

      allow(ENV).to receive(:[]).and_return(nil)
      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
      allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return(organization)

      stub_request(:get, "https://api.github.com/repos/#{organization}/#{repository_name}")
        .with(
          headers: {
            'Accept'=>'application/vnd.github.v3+json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'token test_token',
            'User-Agent'=>'Octokit Ruby Gem 9.1.0'
          }
        )
        .to_return(status: 404, body: '', headers: {})

      assignment = Assignment.new(repository_name: repository_name)
      expect(assignment.send(:remote_repo_created?)).to be false
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
