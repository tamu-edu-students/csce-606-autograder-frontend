# spec/controllers/application_controller_spec.rb
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let!(:user) { User.create!(name: "Test User", email: "test@example.com") }

  describe '#current_user' do
    # Using the `send` method to access the private method
    def current_user
      controller.send(:current_user)
    end

    context 'when user is logged in' do
      before do
        # Simulate a logged-in user by setting the session[:user_id]
        session[:user_id] = user.id
      end

      it 'returns the current user' do
        expect(current_user).to eq(user)
      end
    end

    context 'when user is not logged in' do
      before do
        # Ensure the session[:user_id] is nil
        session[:user_id] = nil
      end

      it 'returns nil' do
        expect(current_user).to be_nil
      end
    end

    context 'when session[:user_id] does not match any user' do
      before do
        # Set session[:user_id] to an ID that does not exist
        session[:user_id] = -1
      end

      it 'returns nil' do
        expect(current_user).to be_nil
      end
    end
  end
end
