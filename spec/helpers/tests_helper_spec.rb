require 'rails_helper'

RSpec.describe TestsHelper, type: :helper do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
  let(:auth_token) { 'mock_github_token' }
  let(:assignment) { double('Assignment') }

  before do
    helper.instance_variable_set(:@assignment, assignment)
    allow(helper).to receive(:session).and_return({ user_id: user.id, github_token: auth_token })
  end

  describe '#update_remote' do
    it 'calls push_changes_to_github on the @assignment with user and auth_token' do
      expect(assignment).to receive(:push_changes_to_github).with(user, auth_token)
      helper.update_remote(user, auth_token)
    end
  end

  describe '#current_user_and_token' do
    it 'returns the current user and auth token' do
      expect(User).to receive(:find).with(user.id).and_return(user)

      result = helper.current_user_and_token

      expect(result).to eq([ user, auth_token ])
    end
  end
end
