# spec/models/user_spec.rb
require 'rails_helper'
require 'omniauth'

RSpec.describe User, type: :model do
  describe '.find_or_create_by_auth_hash' do
    let(:auth_hash) do OmniAuth::AuthHash.new({
        provider: 'github',
        uid: '12345',
        info: {
          name: 'Alice Smith',
          email: 'alice@example.com',
          nickname: 'alicesmith',
          role: 'instructor'
        },
        credentials: {
          token: 'mock_token',
          expires: false
        }
      })
    end

    context 'when the user already exists' do
      before do
        User.create!(provider: 'github', uid: '12345', name: 'Old Name', email: 'old@example.com', role: 'student')
      end

      it 'updates the existing user' do
        user = User.find_or_create_by_auth_hash(auth_hash)

        expect(user).to be_persisted
        expect(user.name).to eq('Alice Smith')
        expect(user.email).to eq('alice@example.com')
        expect(user.role).to eq('instructor')
      end
    end

    context 'when the user does not exist' do
      it 'creates a new user' do
        user = User.find_or_create_by_auth_hash(auth_hash)

        expect(user).to be_persisted
        expect(user.provider).to eq('github')
        expect(user.uid).to eq('12345')
        expect(user.name).to eq('Alice Smith')
        expect(user.email).to eq('alice@example.com')
        expect(user.role).to eq('instructor')
      end
    end

    context 'when there is an error saving the user' do
      before do
        allow_any_instance_of(User).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'raises an error' do
        expect {
          User.find_or_create_by_auth_hash(auth_hash)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
