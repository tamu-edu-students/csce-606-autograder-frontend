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
end
