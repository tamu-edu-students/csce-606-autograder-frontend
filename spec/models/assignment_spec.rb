require 'rails_helper'
require 'webmock/rspec'
require 'open3'
require 'octokit'

RSpec.describe Assignment, type: :model do
  let(:assignment) { Assignment.new(repository_name: 'test-repo', assignment_name: 'Test Assignment') }
  let(:user) { instance_double('User', name: 'testuser') }
  let(:assignment) { Assignment.new(repository_name: 'test_repo') }
  let(:local_repo_path) { File.join(ENV['ASSIGNMENTS_BASE_PATH'], assignment.repository_name) }
  let(:auth_token) { 'fake_auth_token' }
  let(:remote_url) { "https://#{auth_token}@github.com/#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{assignment.repository_name}.git" }
  let(:git) { instance_double('Git::Base') } # Define git here

  before do
    # Set the environment variable for the test
    allow(ENV).to receive(:[]).and_return(nil)
    allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
    allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return('philipritchey/autograded-assignment-template')
    allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('AutograderFrontend')
    allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('assignment-repos/')
  end

  describe '#create_and_add_deploy_key' do
    let(:key_path) { File.join("destination_path", "secrets", "deploy_key") }

    before do
      allow(Open3).to receive(:capture3).and_return([ 'Key generated successfully', '', double(success?: true) ])
      allow(File).to receive(:read).with("#{key_path}.pub").and_return('mock_public_key_content')
      allow(Octokit::Client).to receive(:new).and_return(double('OctokitClient', add_deploy_key: true))
    end

    it 'generates an SSH key' do
      key_path = File.join("destination_path", "secrets", "deploy_key")
      expect(Open3).to receive(:capture3).with('ssh-keygen', '-t', 'ed25519', '-C', 'gradescope', '-f', key_path, "-N", "")
      assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path')
    end

    it 'reads the generated public key' do
      expect(File).to receive(:read).with("#{key_path}.pub")
      assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path')
    end

    it 'adds a deploy key to the GitHub repository' do
      client = double('OctokitClient')
      allow(Octokit::Client).to receive(:new).and_return(client)
      expect(client).to receive(:add_deploy_key).with('organization_name/repo_name', 'Gradescope Deploy Key', 'mock_public_key_content', read_only: true)
      assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path')
    end

    context 'when SSH key generation fails' do
      context 'when Errno::ENOENT is raised' do
        it 'outputs "Command not found"' do
          allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT, "Command not found")

          expect { assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path') }
            .to output(/Command not found: No such file or directory - Command not found/).to_stdout
        end
      end

      context 'when StandardError is raised' do
        it 'outputs "Failed to generate SSH key"' do
          allow(Open3).to receive(:capture3).and_raise(StandardError, "Some error message")

          expect { assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path') }
            .to output(/Failed to generate SSH key: Some error message/).to_stdout
        end
      end
    end

    context 'when reading the public key fails' do
      before do
        allow(File).to receive(:read).and_raise(StandardError.new('File read error'))
      end

      it 'logs an error message' do
        expect { assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path') }.to output(/Failed to read public key: File read error/).to_stdout
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
        expect { assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path') }.to output(/Failed to add deploy key to GitHub: GitHub API error/).to_stdout
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
        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        assignment.send(:create_repo_from_template, 'test_token')
        expect(assignment.repository_url).to eq('https://github.com/AutograderFrontend/test-repository.git')
      end
    end

    context 'when repo creation is unsuccessful' do
      let(:client) { instance_double(Octokit::Client) }

      before do
        client = double('OctokitClient')
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:create_repo_from_template).and_raise(Octokit::Error.new(
            { status: 422,
            body: { message: "GitHub API error" },
            headers: {} }))
      end

      it 'raises a GitHub API Error' do
        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        expect { assignment.send(:create_repo_from_template, 'test_token') }.to output(/Failed to clone repo from assignment template: GitHub API error/).to_stdout
      end
    end
  end

  describe 'clone_repo_to_local' do
    assignment_name = 'Test Assignment'
    repository_name = 'test-repository'

    before do
      allow(Git).to receive(:clone)
    end
    context 'when Git clone is successful' do
      it 'clones the repository without errors' do
        puts "assignment_name: #{assignment_name}"
        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        puts "assignment.local_repository_path: #{assignment.local_repository_path}"
        puts "assignment.repository_url: #{assignment.repository_url}"
        puts "assignment.repository_name: #{assignment.repository_name}"
        expect(Git).to receive(:clone).with(assignment.repository_url, assignment.local_repository_path).and_return(true)
        assignment.send(:clone_repo_to_local)
      end
    end
    context 'when Git clone raises an error' do
      before do
        allow(Git).to receive(:clone).and_raise(Git::Error.new("Failed to clone"))
      end
      it 'rescues the error and prints the error message' do
        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        expect { assignment.send(:clone_repo_to_local) }.to output(/An error occurred: Failed to clone/).to_stdout
      end
    end
  end

  describe 'remote_repo_created?' do
    assignment_name = 'Test Assignment'
    repository_name = 'test-repository'
    organization = 'AutograderFrontend'

    context 'if the repository check API call is successful' do
      it 'returns true if a repo exists on GitHub' do
        client = instance_double(Octokit::Client)
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:repository?).and_return(true)

        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        expect(assignment.send(:remote_repo_created?, "test_token")).to be true
      end

      it 'returns false if the repo does not exist on GitHub' do
        client = instance_double(Octokit::Client)
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:repository?).and_return(false)

        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        expect(assignment.send(:remote_repo_created?, "test_token")).to be false
      end
    end

    context 'if the repository check API call is unsuccessful' do
      it 'raises a GitHub API Error' do
        client = instance_double(Octokit::Client)
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:repository?).and_raise(Octokit::Error.new({ status: 422, body: { message: 'GitHub API Error' }, headers: {} }))
        assignment = Assignment.new(assignment_name: assignment_name, repository_name: repository_name)
        expect { assignment.send(:remote_repo_created?, "test_token") }.to output(/Failed to check whether remote repo has been created: GitHub API Error/).to_stdout
      end
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

      stub_request(:post, "https://api.github.com/repos/AutograderFrontend/test-repository/keys")
        .with(
          body: "{\"read_only\":true,\"title\":\"Gradescope Deploy Key\",\"key\":\"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGh73qHRllHRCY+yNjmBAkHEnZajBpGGDaAdhf6sNzUp gradescope\\n\"}",
          headers: {
            'Accept'=>'application/vnd.github.v3+json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'token test_token',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Octokit Ruby Gem 9.1.0'
          }
        ).to_return(status: 200, body: "", headers: {})

        client = double('OctokitClient')
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:add_deploy_key).and_return(true)

      assignment.send(:assignment_repo_init, 'test_token')

      expect(assignment).to have_received(:create_repo_from_template)
      expect(assignment).to have_received(:clone_repo_to_local)
    end
  end

  before do
    # Stub the environment variables
    allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('/path/to/assignments')
    allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('course_org')

    # Mock Git commands
    allow(Git).to receive(:open).with(local_repo_path).and_return(git)

    # Mocking the 'origin' remote and stubbing url= method
    remote = instance_double('Git::Remote', name: 'origin', url: 'old_url')
    allow(git).to receive(:remotes).and_return([ remote ])
    allow(remote).to receive(:url=)
    allow(git).to receive(:add_remote)

    allow(git).to receive(:add).with(all: true)
    allow(git).to receive(:commit).with("Changes made by #{user.name}")
    allow(git).to receive(:push).with('origin', 'main')

    # Stub the system call to set the remote URL
    allow(assignment).to receive(:system).with("git -C #{local_repo_path} remote set-url origin #{remote_url}")

    # Mock file system checks
    allow(Dir).to receive(:exist?).with(local_repo_path).and_return(true)
  end

  describe '#set_remote_origin' do
    context 'when the origin remote already exists' do
      it 'updates the remote URL' do
        expect(Git).to receive(:open).with(local_repo_path).and_return(git)
        expect(git).to receive(:remotes).and_return([ git.remotes.first ]) # Using mock remote
        expect(git.remotes.first).to receive(:url=).with(remote_url)

        assignment.set_remote_origin(local_repo_path, remote_url)
      end
    end

    context 'when the origin remote does not exist' do
      it 'adds the remote with the given URL' do
        # Set the remotes to be empty to simulate no origin
        allow(git).to receive(:remotes).and_return([])

        expect(git).to receive(:add_remote).with('origin', remote_url)

        assignment.set_remote_origin(local_repo_path, remote_url)
      end
    end
  end

  describe '#push_changes_to_github' do
    it 'commits local changes and pushes to the remote repository if the local repository exists' do
      expect(assignment).to receive(:commit_local_changes).with(local_repo_path, user)
      expect(assignment).to receive(:sync_to_github).with(local_repo_path)

      # Call the method
      assignment.push_changes_to_github(user, auth_token)
    end

    it 'logs an error if the local repository does not exist' do
      # Simulate the repo not existing
      allow(Dir).to receive(:exist?).with(local_repo_path).and_return(false)

      expect(Rails.logger).to receive(:error).with("Local repository not found for #{assignment.repository_name}")

      # Call the method
      assignment.push_changes_to_github(user, auth_token)
    end
  end

  describe '#commit_local_changes' do
    it 'adds and commits changes to the local repository' do
      expect(Git).to receive(:open).with(local_repo_path).and_return(git)
      expect(git).to receive(:add).with(all: true)
      expect(git).to receive(:commit).with("Changes made by #{user.name}")

      assignment.send(:commit_local_changes, local_repo_path, user)
    end

    context 'when an error occurs while committing' do
      it 'raises an error' do
        allow(Git).to receive(:open).with(local_repo_path).and_raise(Git::GitExecuteError.new('Git error'))

        expect { assignment.send(:commit_local_changes, local_repo_path, user) }
          .to raise_error(Git::GitExecuteError, 'Git error')
      end
    end
  end

  describe '#sync_to_github' do
    it 'pushes changes to the GitHub repository' do
      expect(Git).to receive(:open).with(local_repo_path).and_return(git)
      expect(git).to receive(:push).with('origin', 'main')

      assignment.send(:sync_to_github, local_repo_path)
    end

    context 'when an error occurs while pushing' do
      it 'raises an error' do
        allow(Git).to receive(:open).with(local_repo_path).and_raise(Git::GitExecuteError.new('Push error'))

        expect { assignment.send(:sync_to_github, local_repo_path) }
          .to raise_error(Git::GitExecuteError, 'Push error')
      end
    end
  end
end
