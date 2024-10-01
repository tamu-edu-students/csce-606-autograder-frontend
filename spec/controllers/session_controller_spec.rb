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

    it "sets the session for the user and redirects to assignments path" do
      allow(User).to receive(:find_or_create_by_auth_hash).and_return(@user) # Use @user here

      post :create

      expect(session[:user_id]).to eq(@user.id)
      expect(response).to redirect_to(assignments_path)
    end
  end

  describe "when the user is not a member of the required GitHub organization" do
    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_hash)
      allow_any_instance_of(Octokit::Client).to receive(:organization_member?).and_return(false)
    end

    it "does not create the user and redirects with an alert" do
      post :create

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You must be a member of CSCE-120 organization to access this application.')
    end
  end

  describe "when auth_hash is not present" do
    before do
      request.env['omniauth.auth'] = nil
    end

    it "redirects to root path with an authentication failure alert" do
      post :create

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('GitHub authentication failed. Please try again.')
    end
  end

  describe "when token is invalid" do
    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_hash)
      allow_any_instance_of(Octokit::Client).to receive(:organization_member?).and_raise(Octokit::Unauthorized)
    end

    it "it returns false and redirects to root path with an organization membership alert" do
      post :create
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You must be a member of CSCE-120 organization to access this application.')
    end
  end

end
