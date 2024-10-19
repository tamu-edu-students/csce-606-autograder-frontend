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

  describe '#require_login' do
    controller do
      # Define a sample action to test the filter
      before_action :require_login

      def index
        render plain: "This is the index page"
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id  # Simulate logged-in user
        get :index  # Trigger the before_action
      end

      it 'does not redirect the user' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      before do
        session[:user_id] = nil  # Simulate a logged-out user
        get :index  # Trigger the before_action
      end

      it 'redirects the user to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets the flash alert message' do
        expect(flash[:alert]).to eq("Please log in to access this page")
      end
    end
  end
end
