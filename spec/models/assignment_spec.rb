require 'rails_helper'
require 'git'

RSpec.describe Assignment, type: :model do
  let(:user) { instance_double('User', username: 'testuser') }
  let(:assignment) { Assignment.new(repository_name: 'test_repo') }
  let(:local_repo_path) { File.join(ENV['ASSIGNMENTS_BASE_PATH'], assignment.repository_name) }
  let(:auth_token) { 'fake_auth_token' }
  let(:remote_url) { "https://#{auth_token}@github.com/#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{assignment.repository_name}.git" }

  let(:git) { instance_double('Git::Base') } # Define git here

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
    allow(git).to receive(:commit).with("Changes made by #{user.username}")
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
      expect(git).to receive(:commit).with("Changes made by #{user.username}")

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
