require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe 'create_repo_from_tempalte' do
    it 'creates a new repo from a template' do
      assignment = Assignment.new(assignment_name: 'Test Assignment', repository_name: 'Test Repository')
      allow(assignment).to receive(:create_repo_from_template).and_return({ html_url: 
  end
end
