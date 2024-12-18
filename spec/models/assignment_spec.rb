require 'rails_helper'
require 'webmock/rspec'
require 'open3'
require 'octokit'

RSpec.describe Assignment, type: :model do
  let(:user) { instance_double('User', name: 'testuser', email: 'test-email@test.net') }
  let(:assignment) { Assignment.new(assignment_name: 'test_assignment', repository_name: 'test_repo', repository_url: 'https://github.com/user/test-repository.git') }
  let(:local_repo_path) { File.join(ENV['ASSIGNMENTS_BASE_PATH'], assignment.repository_name) }
  let(:auth_token) { 'fake_auth_token' }
  let(:remote_url) { "https://#{auth_token}@github.com/#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{assignment.repository_name}.git" }
  let(:git) { instance_double('Git::Base') } # Define git here
  let(:client) { double('OctokitClient', add_deploy_key: true) }
  let(:authenticated_url) { 'https://fake_auth_token@github.com/user/test-repository.git' }

  before do
    # Set the environment variable for the test
    allow(ENV).to receive(:[]).and_return(nil)
    allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
    allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return('philipritchey/autograded-assignment-template')
    allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('AutograderFrontend')
    allow(ENV).to receive(:[]).with('ASSIGNMENTS_BASE_PATH').and_return('assignment-repos/')
    allow(ENV).to receive(:[]).with('GITHUB_AUTOGRADER_CORE_REPO').and_return('autograder-core')
  end

  after do
    FileUtils.rm_rf(ENV['ASSIGNMENTS_BASE_PATH'])
  end

  describe '#create_and_add_deploy_key' do
    let(:key_path) { File.join("destination_path", "secrets", "deploy_key") }
    let(:mock_client) { double('OctokitClient', add_deploy_key: true) }

    before do
      allow(Open3).to receive(:capture3).and_return([ 'Key generated successfully', '', double(success?: true) ])
      allow(File).to receive(:read).with("#{key_path}.pub").and_return('mock_public_key_content')
      allow(Octokit::Client).to receive(:new).and_return(mock_client)
    end

    after do
      FileUtils.rm_rf(File.join("destination_path", "secrets"))
    end

    subject(:create_deploy_key) do
      assignment.send(:create_and_add_deploy_key, 'test_token', 'repo_name', 'organization_name', 'destination_path')
    end

    it 'generates an SSH key' do
      expect(Open3).to receive(:capture3).with('ssh-keygen', '-t', 'ed25519', '-C', 'gradescope', '-f', key_path, "-N", "")
      create_deploy_key
    end

    it 'reads the generated public key' do
      expect(File).to receive(:read).with("#{key_path}.pub")
      create_deploy_key
    end

    it 'adds a deploy key to the GitHub repository' do
      expect(mock_client).to receive(:add_deploy_key).with('organization_name/repo_name', 'Gradescope Deploy Key', 'mock_public_key_content', read_only: true)
      create_deploy_key
    end

    describe 'when SSH key generation fails' do
      shared_examples 'logs error messages' do |error_class, error_message, expected_output|
        before { allow(Open3).to receive(:capture3).and_raise(error_class, error_message) }

        it "outputs \"#{expected_output}\"" do
          expect { create_deploy_key }.to output(/#{expected_output}/).to_stdout
        end
      end

      it_behaves_like 'logs error messages', Errno::ENOENT, "Command not found", "Command not found: No such file or directory - Command not found"
      it_behaves_like 'logs error messages', StandardError, "Some error message", "Failed to generate SSH key: Some error message"
    end

    describe 'when reading the public key fails' do
      before { allow(File).to receive(:read).and_raise(StandardError.new('File read error')) }

      it 'logs an error message' do
        expect { create_deploy_key }.to output(/Failed to read public key: File read error/).to_stdout
      end
    end

    context 'when adding the deploy key to GitHub fails' do
      before do
        allow(mock_client).to receive(:add_deploy_key).and_raise(Octokit::Error.new({ body: { message: "GitHub API error" } }))
      end

      it 'logs an error message' do
        expect { create_deploy_key }.to output(/Failed to add deploy key to GitHub: GitHub API error/).to_stdout
      end
    end
  end
  describe '#create_repo_from_template' do
    let(:assignment_name) { 'Test Assignment' }
    let(:repository_name) { 'test-repository' }
    let(:organization) { 'AutograderFrontend' }
    let(:template_repo) { 'philipritchey/autograded-assignment-template' }
    let(:assignment) { Assignment.new(assignment_name: assignment_name, repository_name: repository_name) }

    it 'creates a new repo from a template when successful' do
      stub_request(:post, "https://api.github.com/repos/philipritchey/autograded-assignment-template/generate").
        with(
          body: "{\"owner\":\"AutograderFrontend\",\"name\":\"test-repository\",\"private\":true}",
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

      assignment.send(:create_repo_from_template, 'test_token')
      expect(assignment.repository_url).to eq('https://github.com/AutograderFrontend/test-repository.git')
    end

    it 'raises an error when repo creation is unsuccessful' do
      client = double('OctokitClient')
      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(client).to receive(:create_repo_from_template).and_raise(Octokit::Error.new({ body: { message: "GitHub API error" } }))

      expect { assignment.send(:create_repo_from_template, 'test_token') }.to output(/Failed to clone repo from assignment template: GitHub API error/).to_stdout
    end
  end

  describe '#clone_repo_to_local' do
    let(:assignment) { Assignment.new(assignment_name: 'Test Assignment', repository_name: 'test-repository', repository_url: 'https://github.com/user/test-repository.git') }

    before do
      allow(Git).to receive(:clone)
      allow(FileUtils).to receive(:rm_rf)
    end

    it 'removes a local clone if it already exists' do
      allow(Dir).to receive(:exist?).with(local_repo_path).and_return(true)
      allow(Dir).to receive(:exist?).with("#{local_repo_path}/.git").and_return(false)
      assignment.send(:clone_repo_to_local, auth_token)
      expect(FileUtils).to have_received(:rm_rf).with(local_repo_path)
    end

    it 'clones the repository successfully' do
      allow(Dir).to receive(:exist?).with(local_repo_path).and_return(false)
      expect(Git).to receive(:clone).with(authenticated_url, assignment.local_repository_path).and_return(true)
      assignment.send(:clone_repo_to_local, auth_token)
    end

    it 'rescues the error when Git clone fails' do
      allow(Dir).to receive(:exist?).with(local_repo_path).and_return(false)
      allow(Git).to receive(:clone).and_raise(Git::Error.new("Failed to clone"))
      expect { assignment.send(:clone_repo_to_local, auth_token) }.to output(/An error occurred: Failed to clone/).to_stdout
    end
  end


  describe '#remote_repo_created?' do
    let(:assignment) { Assignment.new(assignment_name: 'Test Assignment', repository_name: 'test-repository') }
    let(:client) { instance_double(Octokit::Client) }

    before do
      allow(Octokit::Client).to receive(:new).and_return(client)
    end

    context 'when the repository check API call is successful' do
      it 'returns true if the repo exists on GitHub' do
        allow(client).to receive(:repository?).and_return(true)
        expect(assignment.send(:remote_repo_created?, 'test_token')).to be true
      end

      it 'returns false if the repo does not exist on GitHub' do
        allow(client).to receive(:repository?).and_return(false)
        expect(assignment.send(:remote_repo_created?, 'test_token')).to be false
      end
    end

    context 'when the repository check API call is unsuccessful' do
      it 'raises a GitHub API Error' do
        allow(client).to receive(:repository?).and_raise(Octokit::Error.new({ body: { message: 'GitHub API Error' } }))
        expect { assignment.send(:remote_repo_created?, 'test_token') }.to output(/Failed to check whether remote repo has been created: GitHub API Error/).to_stdout
      end
    end
  end


  describe '#assignment_repo_init' do
    it 'creates a new repo from a template and clones it locally' do
      assignment = Assignment.new(
        assignment_name: 'Test Assignment',
        repository_name: 'test-repository'
      )

      # mock
      allow(assignment).to receive(:create_repo_from_template)
      allow(assignment).to receive(:clone_repo_to_local)
      allow(assignment).to receive(:init_run_autograder_script)

      client = double('OctokitClient')
      allow(Octokit::Client).to receive(:new).and_return(client)
      expect(client).to receive(:add_deploy_key).with('AutograderFrontend/test-repository', 'Gradescope Deploy Key', anything, read_only: true)
      expect(client).to receive(:add_deploy_key).with('AutograderFrontend/autograder-core', 'Gradescope Deploy Key', anything, read_only: true)

      assignment.send(:assignment_repo_init, 'test_token', user)

      expect(assignment).to have_received(:create_repo_from_template)
      expect(assignment).to have_received(:clone_repo_to_local)
      expect(assignment).to have_received(:init_run_autograder_script)
    end
  end

  before do
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
    before do
      allow(assignment).to receive(:clone_repo_to_local).with(auth_token)
    end

    it 'reclones the remote repository, commits local changes and pushes to the remote repository' do
      expect(assignment).to receive(:clone_repo_to_local).with(auth_token)
      expect(assignment).to receive(:commit_local_changes).with(local_repo_path, user)
      expect(assignment).to receive(:sync_to_github).with(local_repo_path)

      assignment.push_changes_to_github(user, auth_token)
    end

    it 'logs an error if local repository is not found after cloning step' do
      allow(Dir).to receive(:exist?).with(local_repo_path).and_return(false)
      expect(Rails.logger).to receive(:error).with("Local repository not found for #{assignment.repository_name}")

      assignment.push_changes_to_github(user, auth_token)
    end
  end

  describe '#commit_local_changes' do
    it 'adds and commits changes to the local repository' do
      expect(Git).to receive(:open).with(local_repo_path).and_return(git)
      expect(git).to receive(:config).with("user.name", user.name)
      expect(git).to receive(:config).with("user.email", anything)
      expect(git).to receive(:add).with(all: true)
      expect(git).to receive(:commit).with("Changes made by #{user.name}")

      assignment.send(:commit_local_changes, local_repo_path, user)
    end

    context 'when an error occurs while committing' do
      it 'catches the error and outputs an error message' do
        allow(Git).to receive(:open).with(local_repo_path).and_raise(Git::GitExecuteError.new('Git error'))

        expect(assignment).to receive(:puts).with("Error in commiting: Git error")

        expect {
          assignment.send(:commit_local_changes, local_repo_path, user)
        }.not_to raise_error
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

  describe '#fetch_directory_structure' do
    let(:github_token) { 'test_github_token' }
    let(:assignment) { Assignment.new(assignment_name: 'Test Assignment', repository_name: repository_name) }
    let(:client) { instance_double(Octokit::Client) }
    let(:organization) { 'AutograderFrontend' }
    let(:repository_name) { 'test_repo' }
    let(:repo_path) { "#{organization}/#{repository_name}" }
    let(:directory_content) do
      [
        { type: 'dir', name: 'folder1', path: 'tests/folder1' },
        { type: 'file', name: 'file1.txt', path: 'tests/file1.txt' }
      ]
    end
    let(:folder1_content) do
      [
        { type: 'file', name: 'file2.txt', path: 'tests/folder1/file2.txt' }
      ]
    end

    before do
      allow(Octokit::Client).to receive(:new).and_return(client)
      # Stub for the root 'tests' directory
      allow(client).to receive(:contents).with(repo_path, path: 'tests').and_return(directory_content)
      # Stub for the 'tests/folder1' directory, to handle recursion in build_file_tree
      allow(client).to receive(:contents).with(repo_path, path: 'tests/folder1').and_return(folder1_content)
    end

    it 'returns the file tree structure for the tests directory' do
      result = assignment.fetch_directory_structure(github_token)
      expect(result).to be_an(Array)
      expect(result.first[:name]).to eq('folder1')
      expect(result.first[:type]).to eq('directory')
      expect(result.first[:children].first[:name]).to eq('file2.txt')
      expect(result.first[:children].first[:type]).to eq('file')
    end

    it 'logs an error and returns an empty array if a GitHub API error occurs' do
      allow(client).to receive(:contents).with(repo_path, path: 'tests').and_raise(Octokit::Error.new({ message: "GitHub API Error" }))

      expect(Rails.logger).to receive(:error).with(/GitHub API Error/)
      expect(assignment.fetch_directory_structure(github_token)).to eq([])
    end
  end


  describe '#upload_file_to_repo' do
    let(:file) { fixture_file_upload('spec/fixtures/test_file.txt', 'text/plain') }
    let(:github_token) { 'test_github_token' }
    let(:path) { 'folder1' }
    let(:client) { instance_double(Octokit::Client) }
    let(:repo_name) { "#{ENV['GITHUB_COURSE_ORGANIZATION']}/#{assignment.repository_name}" }
    let(:file_content) { 'Test file content' }

    before do
      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(file).to receive(:read).and_return(file_content)
    end

    context 'when the file upload is successful' do
      before do
        allow(client).to receive(:create_contents).with(
          repo_name,
          "tests/#{path}/#{file.original_filename}",
          "Upload #{file.original_filename}",
          file_content
        ).and_return(success: true)
      end

      it 'uploads the file to the specified path in the GitHub repo' do
        expect(assignment.upload_file_to_repo(file, path, github_token)).to be true
      end
    end

    context 'when file or path parameters are missing' do
      it 'returns false if file is missing' do
        expect(assignment.upload_file_to_repo(nil, path, github_token)).to be false
      end

      it 'returns false if path is missing' do
        expect(assignment.upload_file_to_repo(file, nil, github_token)).to be false
      end
    end

    context 'when a GitHub API error occurs' do
      before do
        allow(client).to receive(:create_contents).and_raise(Octokit::Error.new(message: 'GitHub API Error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and returns false' do
        expect(Rails.logger).to receive(:error).with(/GitHub API Error/)
        expect(assignment.upload_file_to_repo(file, path, github_token)).to be false
      end
    end
  end

  describe '#init_run_autograder_script' do
    let(:local_repository_path) { 'assignment-path' }
    let(:files_to_submit) { { 'files_to_submit' => [ 'main.cpp', 'helper.cpp', 'helper.h' ] } }
    let(:run_autograder_path) { File.join(local_repository_path, 'run_autograder') }
    let(:original_file_content) do
      <<~SCRIPT
        #!/usr/bin/env bash

        # TODO: list files that student must submit
        files_to_submit=( code.cpp code_tests.cpp code_interactive.cpp code.h )

        #
        # Provided by instructor
        #
        provided_files=( )
      SCRIPT
    end
    let(:expected_file_content) do
      <<~SCRIPT
        #!/usr/bin/env bash

        # TODO: list files that student must submit
        files_to_submit=( main.cpp helper.cpp helper.h )

        #
        # Provided by instructor
        #
        provided_files=( )
      SCRIPT
    end
    before do
      allow(assignment).to receive(:local_repository_path).and_return(local_repository_path)
      allow(assignment).to receive(:files_to_submit).and_return(files_to_submit)
      allow(File).to receive(:join).with(local_repository_path, 'run_autograder').and_return(run_autograder_path)
      allow(File).to receive(:read).with(run_autograder_path).and_return(original_file_content)
      allow(File).to receive(:open).with(run_autograder_path, 'w').and_yield(double('file', write: true))
      allow(assignment).to receive(:push_changes_to_github).and_return(true)
    end

    it 'replaces files_to_submit with new files in the file content' do
      assignment.send(:init_run_autograder_script, 'test_token', user)
      expect(File.read(run_autograder_path)).to eq(expected_file_content)
    end
  end

  describe '#generate_and_rename_zip' do
    let(:assignment) { create(:assignment, repository_name: 'test-repository', assignment_name: 'Test Assignment') }
    let(:github_token) { 'fake_github_token' }
    let(:local_repository_path) { '/fake/local/repo/path' }
    let(:original_zip_file) { File.join(local_repository_path, 'autograder.zip') }
    let(:new_zip_filename) { "#{assignment.assignment_name}.zip" }
    let(:renamed_zip_path) { File.join(local_repository_path, new_zip_filename) }

    before do
      allow(assignment).to receive(:local_repository_path).and_return(local_repository_path)
    end

    context 'when the local repository does not exist' do
      before do
        allow(Dir).to receive(:exist?).with(local_repository_path).and_return(false)
        allow(assignment).to receive(:clone_repo_to_local).with(github_token)
      end

      it 'clones the repository to the local path' do
        expect(assignment).to receive(:clone_repo_to_local).with(github_token)
        assignment.generate_and_rename_zip(github_token)
      end
    end

    context 'when the local repository exists' do
      before do
        allow(Dir).to receive(:exist?).with(local_repository_path).and_return(true)
      end

      it 'does not clone the repository again' do
        expect(assignment).not_to receive(:clone_repo_to_local)
        assignment.generate_and_rename_zip(github_token)
      end
    end

    context 'when the local repository path is missing after cloning' do
      before do
        allow(Dir).to receive(:exist?).with(local_repository_path).and_return(false)
        allow(assignment).to receive(:clone_repo_to_local).with(github_token)
      end

      it 'returns nil' do
        result = assignment.generate_and_rename_zip(github_token)
        expect(result).to be_nil
      end
    end

    context 'when the repository exists and make command is executed' do
      before do
        allow(Dir).to receive(:exist?).with(local_repository_path).and_return(true)
        allow(Dir).to receive(:chdir).with(local_repository_path).and_yield
        allow_any_instance_of(Object).to receive(:system).with('make').and_return(true)
      end

      context 'when the ZIP file is successfully generated and renamed' do
        before do
          allow(File).to receive(:exist?).with(original_zip_file).and_return(true)
          allow(File).to receive(:rename).with(original_zip_file, renamed_zip_path)
          allow(File).to receive(:exist?).with(renamed_zip_path).and_return(true)
        end

        it 'renames the ZIP file' do
          expect(File).to receive(:rename).with(original_zip_file, renamed_zip_path)
          assignment.generate_and_rename_zip(github_token)
        end

        it 'returns the renamed ZIP file path' do
          result = assignment.generate_and_rename_zip(github_token)
          expect(result).to eq(renamed_zip_path)
        end
      end

      context 'when the ZIP file is not found after generation' do
        before do
          allow(File).to receive(:exist?).with(original_zip_file).and_return(false)
          allow(File).to receive(:exist?).with(renamed_zip_path).and_return(false)
        end

        it 'does not rename the ZIP file' do
          expect(File).not_to receive(:rename)
          assignment.generate_and_rename_zip(github_token)
        end

        it 'returns nil' do
          result = assignment.generate_and_rename_zip(github_token)
          expect(result).to be_nil
        end
      end

      context 'when the renamed ZIP file is not found' do
        before do
          allow(File).to receive(:exist?).with(original_zip_file).and_return(true)
          allow(File).to receive(:rename).with(original_zip_file, renamed_zip_path)
          allow(File).to receive(:exist?).with(renamed_zip_path).and_return(false)
        end

        it 'returns nil' do
          result = assignment.generate_and_rename_zip(github_token)
          expect(result).to be_nil
        end
      end
    end

    context 'when an error occurs' do
      before do
        allow(Dir).to receive(:exist?).with(local_repository_path).and_return(true)
        allow(Dir).to receive(:chdir).with(local_repository_path).and_raise(StandardError, 'An error occurred')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and returns nil' do
        result = assignment.generate_and_rename_zip(github_token)
        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with('Error generating ZIP: An error occurred')
      end
    end
  end
end
