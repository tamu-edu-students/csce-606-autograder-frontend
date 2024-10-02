require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the AssignmentsHelper. For example:
#
# describe AssignmentsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe AssignmentsHelper, type: :helper do
  describe 'create_repo_from_template' do
    it 'creates a new repository from a template' do
      assignment = Assignment.create(assignment_name: 'Test Assignment', repository_name: 'Test Repository', repository_url: '')
      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('test_token')
      allow(ENV).to receive(:[]).with('GITHUB_TEMPLATE_REPO_URL').and_return('test_template_repo')
      allow(ENV).to receive(:[]).with('GITHUB_COURSE_ORGANIZATION').and_return('test_organization')
      client = double('client')
      allow(Octokit::Client).to receive(:new).with(access_token: 'test_token').and_return(client)
      allow(client).to receive(:create_repo_from_template).with('test_template_repo', 'test-repository', { owner: 'test_organization', name: 'Test Assignment', private: true }).and_return({ html_url: 'github.com/test_organization/test-repository' })
      helper.create_repo_from_template(assignment)
      expect(assignment.repository_url).to eq('github.com/test_organization/test-repository')
    end
  end
  describe '.create_and_add_deploy_key' do
    let(:repo_name) { 'username/repository_name' }
    let(:key_path) { './deploy_key' }
    let(:secret_key_path) { './secrets/deploy_key' }
    let(:public_key_content) { "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB..." }
    let(:private_key_content) { "PRIVATE KEY CONTENT" }
    let(:github_access_token) { 'fake_access_token' }
    
    before do
      # Stub environment variable
      allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return(github_access_token)
      # Stub Open3.capture3
      allow(Open3).to receive(:capture3).and_return([nil, '', nil])
      # Stub FileUtils.mv
      allow(FileUtils).to receive(:mv)
      # Stub File.read
      allow(File).to receive(:read).with("#{key_path}.pub").and_return(public_key_content)
      # Stub Octokit client
      @octokit_client = instance_double(Octokit::Client)
      allow(Octokit::Client).to receive(:new).with(access_token: github_access_token).and_return(@octokit_client)
      # Stub add_deploy_key
      allow(@octokit_client).to receive(:add_deploy_key).with(repo_name, "Gradescope Deploy Key", public_key_content, read_only: false)
    end
    describe 'when all steps succeed' do
      it 'generates an SSH key, moves the private key, and adds the deploy key to GitHub' do
        expect(Open3).to receive(:capture3).with("ssh-keygen -t ed25519 -C \"gradescope\" -f #{key_path} -N ''")
        expect(FileUtils).to receive(:mv).with(key_path, secret_key_path)
        expect(File).to receive(:read).with("#{key_path}.pub")
        expect(Octokit::Client).to receive(:new).with(access_token: github_access_token)
        expect(@octokit_client).to receive(:add_deploy_key).with(repo_name, "Gradescope Deploy Key", public_key_content, read_only: false)
        expect { helper.create_and_add_deploy_key(repo_name) }.to output(/Deploy key added successfully for #{repo_name}!/).to_stdout
      end
    end
    describe 'when SSH key generation fails' do
      before do
        allow(Open3).to receive(:capture3).and_raise(StandardError.new('ssh-keygen error'))
      end
      it 'outputs an error message and does not proceed further' do
        expect(Open3).to receive(:capture3).with("ssh-keygen -t ed25519 -C \"gradescope\" -f #{key_path} -N ''").and_raise(StandardError.new('ssh-keygen error'))
        expect(FileUtils).not_to receive(:mv)
        expect(File).not_to receive(:read)
        expect(Octokit::Client).not_to receive(:new)
        expect { helper.create_and_add_deploy_key(repo_name) }.to output(/Failed to generate SSH key: ssh-keygen error/).to_stdout
      end
    end
    describe 'when moving the private key fails' do
      before do
        allow(FileUtils).to receive(:mv).and_raise(StandardError.new('mv error'))
      end
      it 'outputs an error message and does not proceed to add deploy key' do
        expect(Open3).to receive(:capture3).with("ssh-keygen -t ed25519 -C \"gradescope\" -f #{key_path} -N ''")
        expect(FileUtils).to receive(:mv).with(key_path, secret_key_path).and_raise(StandardError.new('mv error'))
        expect(File).not_to receive(:read)
        expect(Octokit::Client).not_to receive(:new)
        expect { helper.create_and_add_deploy_key(repo_name) }.to output(/Failed to move deploy key: mv error/).to_stdout
      end
    end
    describe 'when reading the public key fails' do
      before do
        allow(File).to receive(:read).with("#{key_path}.pub").and_raise(StandardError.new('read error'))
      end
      it 'raises an error when attempting to read the public key' do
        expect(Open3).to receive(:capture3).with("ssh-keygen -t ed25519 -C \"gradescope\" -f #{key_path} -N ''")
        expect(FileUtils).to receive(:mv).with(key_path, secret_key_path)
        expect(File).to receive(:read).with("#{key_path}.pub").and_raise(StandardError.new('read error'))
        expect(Octokit::Client).not_to receive(:new)
        expect { helper.create_and_add_deploy_key(repo_name) }.to output(/Failed to read public key: read error/).to_stdout
      end
    end
    describe 'when adding the deploy key to GitHub fails' do
      before do
        allow(@octokit_client).to receive(:add_deploy_key).and_raise(Octokit::Error.new(
            { status: 422, 
            body: { message: "GitHub API error" }, 
            headers: {} }
        ))

        allow(ENV).to receive(:[]).and_return(nil)
        allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('fake_access_token')
      end
      it 'outputs an error message when GitHub API call fails' do
        expect(Open3).to receive(:capture3).with("ssh-keygen -t ed25519 -C \"gradescope\" -f #{key_path} -N ''")
        expect(FileUtils).to receive(:mv).with(key_path, secret_key_path)
        expect(File).to receive(:read).with("#{key_path}.pub")
        expect(@octokit_client).to receive(:add_deploy_key).with(repo_name, "Gradescope Deploy Key", public_key_content, read_only: false).and_raise(Octokit::Error.new(
            { status: 422, 
            body: { message: "GitHub API error" }, 
            headers: {} }
        ))
        expect { helper.create_and_add_deploy_key(repo_name) }.to output(/Failed to add deploy key to GitHub: GitHub API error/).to_stdout
      end
    end
  end
end
