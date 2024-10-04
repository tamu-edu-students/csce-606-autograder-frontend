require 'rails_helper'
require 'git'

RSpec.describe Assignment, type: :model do
  let(:user) { instance_double('User', username: 'testuser') }
  let(:assignment) { Assignment.new(repository_name: 'test_repo') }
  let(:local_repo_path) { File.join(ENV['ASSIGNMENTS_BASE_PATH'], assignment.repository_name) }
  let(:auth_token) { 'fake_auth_token' }

  before do
    # Stub the environment variables
    allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('/path/to/assignments')
    allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('course_org')

    # Mock Git commands
    git = instance_double('Git::Base')
    allow(Git).to receive(:open).with(local_repo_path).and_return(git)
    allow(git).to receive(:add).with(all: true)
    allow(git).to receive(:commit).with("Changes made by #{user.username}")
    allow(git).to receive(:push).with('origin', 'main')

    # Stub the system call to set the remote URL
    allow(assignment).to receive(:system).with("git -C #{local_repo_path} remote set-url origin https://#{auth_token}:x-oauth-basic@github.com/course_org/test_repo.git")

    # Mock file system checks
    allow(Dir).to receive(:exist?).with(local_repo_path).and_return(true)
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
      git = instance_double('Git::Base')
      allow(Git).to receive(:open).with(local_repo_path).and_return(git)
      expect(git).to receive(:add).with(all: true)
      expect(git).to receive(:commit).with("Changes made by #{user.username}")

      assignment.send(:commit_local_changes, local_repo_path, user)
    end
  end

  describe '#sync_to_github' do
    it 'pushes changes to the GitHub repository' do
      git = instance_double('Git::Base')
      allow(Git).to receive(:open).with(local_repo_path).and_return(git)
      expect(git).to receive(:push).with('origin', 'main')

      assignment.send(:sync_to_github, local_repo_path)
    end
  end
end
