require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:auth_hash) do
    {
      'provider' => 'github',
      'uid' => '12345',
      'info' => {
        'nickname' => 'johndoe',
        'name' => 'John Doe'
      },
      'credentials' => {
        'token' => 'valid_token'
      }
    }
  end

  describe "when the user is a member of the required GitHub organization" do
    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_hash)
      allow_any_instance_of(Octokit::Client).to receive(:organization_member?).and_return(true)
      @user = create(:user, name: 'John Doe') # Moved this here
    end

    it "finds or creates the user" do
      expect(User).to receive(:find_or_create_by_auth_hash).with(OmniAuth::AuthHash.new(auth_hash)).and_return(@user) # Use @user here
      post :create
    end

    it "sets the session for the user" do
      allow(User).to receive(:find_or_create_by_auth_hash).and_return(@user) # Use @user here

      post :create

      expect(session[:user_id]).to eq(@user.id)
    end

    it ' redirects to assignments index path' do
      allow(User).to receive(:find_or_create_by_auth_hash).and_return(@user) # Use @user here

      post :create

      expect(response).to redirect_to(assignments_path)
    end
  end

  describe "when the user is not a member of the required GitHub organization" do
    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_hash)
      allow_any_instance_of(Octokit::Client).to receive(:organization_member?).and_return(false)
    end

    it "does not create the user" do
      post :create

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:warning]).to eq('You must be a member of CSCE-120 organization to access this application.')
    end
  end

  describe "when user logs in with invalid credentials" do
    it "returns an error message and redirects to home page" do
      post :failure

      expect(response).to redirect_to(root_path)
      expect(flash[:warning]).to eq('GitHub authentication failed. Please try again.')
    end
  end
end
