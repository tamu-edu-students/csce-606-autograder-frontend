require 'rails_helper'
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
      allow(Open3).to receive(:capture3).and_return(['Key generated successfully', '', double(success?: true)])
      allow(File).to receive(:read).with("#{key_path}.pub").and_return('mock_public_key_content')
      allow(Octokit::Client).to receive(:new).and_return(double('OctokitClient', add_deploy_key: true))
    end

    it 'generates an SSH key' do
      expect(Open3).to receive(:capture3).with('ssh-keygen', '-t', 'ed25519', '-C', 'gradescope', '-f', key_path)
      assignment.create_and_add_deploy_key
    end

    it 'reads the generated public key' do
      expect(File).to receive(:read).with("#{key_path}.pub")
      assignment.create_and_add_deploy_key
    end

    it 'adds a deploy key to the GitHub repository' do
      client = double('OctokitClient')
      allow(Octokit::Client).to receive(:new).and_return(client)
      expect(client).to receive(:add_deploy_key).with(assignment.repository_name, 'Gradescope Deploy Key', 'mock_public_key_content', read_only: true)
      assignment.create_and_add_deploy_key
    end

    context 'when SSH key generation fails' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', 'Error generating key', double(success?: false)])
      end

      it 'logs an error message' do
        expect { assignment.create_and_add_deploy_key }.to output(/Error generating key/).to_stdout
      end
    end

    context 'when reading the public key fails' do
      before do
        allow(File).to receive(:read).and_raise(StandardError.new('File read error'))
      end

      it 'logs an error message' do
        expect { assignment.create_and_add_deploy_key }.to output(/Failed to read public key: File read error/).to_stdout
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
        expect { assignment.create_and_add_deploy_key }.to output(/Failed to add deploy key to GitHub: GitHub API error/).to_stdout
      end
    end
  end
end
