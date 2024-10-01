require 'rails_helper'


RSpec.describe SessionsController, type: :controller do
    let(:mock_auth_hash) do
        OmniAuth::AuthHash.new({
          provider: 'github',
          uid: '12345',
          info: {
            name: 'Test User',
            email: 'test@example.com',
            nickname: 'testuser'
          },
          credentials: {
            token: 'mock_access_token'
          },
          extra: {
            raw_info: {
              role: "member" 
            }
          }
        })
    end

    describe "when the user is a member of the required GitHub organization" do
        before do
            request.env['omniauth.auth'] = mock_auth_hash
            allow_any_instance_of(Octokit::Client).to receive(:organization_member?).and_return(true) 
        end

        it "finds or creates the user" do
            expect(User).to receive(:find_or_create_by_auth_hash).with(mock_auth_hash)
            get :create, params: { provider: :github }
        end

        it "sets the user_id in the session" do
            get :create, params: { provider: :github }
            expect(session[:user_id]).to eq(User.last.id)
        end

        it "redirects to the root path" do
            get :create, params: { provider: 'github' }
            expect(response).to redirect_to(root_path) 
        end
    end

    # describe "when the user is not a member of the required GitHub organization" do
    #     before do 
    #       OmniAuth.config.mock_auth[:github][:extra][:raw_info][:organizations] = []
    #     end 
  
    #     it "redirects to the home path with an error message" do
    #       get :create, params: { provider: 'github' }
    #       expect(response).to redirect_to(root_path) 
    #       expect(flash[:alert]).to match(/Not authorized/i) 
    #     end
    # end

    # describe "when the user enters invalid email and password" do
    #     before do
    #         OmniAuth.config.mock_auth[:github] = :invalid_credentials 
    #     end
    
    #     it "redirects to the home path with an error message" do
    #       get :create, params: { provider: 'github' }
    #       expect(response).to redirect_to(root_path) 
    #       expect(flash[:alert]).to match(/Not authorized/i) 
    #     end
    # end
end
    