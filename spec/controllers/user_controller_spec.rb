require 'rails_helper'

RSpec.describe UsersController, type: :controller do

    describe "when all the users in the organization are displayed" do

        it "assigns users" do
            user = User.create!(name: 'Test User')
            get :index
            expect(assigns(:users)).to eq([user])
        end
    end

    describe "when the assignments are shown for each user" do
        let(:user) { User.create!(username: 'TestUser') }

        it 'assigns @user' do
            get :show, params: { id: user.id }
            expect(assigns(:user)).to eq(user)
        end

        it 'assigns @assignments' do
            assignment = Assignment.create!(repository_name: 'TestAssignment')
            get :show, params: { id: user.id }
            expect(assigns(:assignments)).to include(assignment)
        end
    end

    describe "when the assignment access for a user is updated" do

        let(:user) { User.create!(name: 'Test User', username: 'testuser') }
        let(:assignment1) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'repo1') }
        let(:assignment2) { Assignment.create!(assignment_name: 'Assignment 2', repository_name: 'repo2') }

        before do
            allow(ENV).to receive(:[]).with('GITHUB_ACCESS_TOKEN').and_return('fake_token')
            @mock_client = double('Octokit::Client')
            allow(Octokit::Client).to receive(:new).and_return(@mock_client)
        end

        it 'updates the assignments' do
            user.assignment_ids = [assignment1.id]
            user.save!
    
            expect_any_instance_of(UsersController).to receive(:update_github_permissions)
            
            post :update_assignments, params: { id: user.id, assignment_ids: [assignment2.id] }
            user.reload
    
            expect(user.assignment_ids).to eq([assignment2.id])
            expect(flash[:notice]).to eq('Assignments updated successfully.')
        end

        it 'redirects to the users index' do
            user.assignment_ids = [assignment1.id]
            user.save!
    
            expect_any_instance_of(UsersController).to receive(:update_github_permissions)
    
            post :update_assignments, params: { id: user.id, assignment_ids: [assignment1.id] }
            expect(response).to redirect_to(users_path)
        end

        it 'updates GitHub permissions correctly' do
            user.assignment_ids = [assignment1.id]
            user.save!
    
            expect(@mock_client).to receive(:add_collaborator).with('AutograderFrontend/repo2', 'testuser', permission: 'push')
            expect(@mock_client).to receive(:remove_collaborator).with('AutograderFrontend/repo1', 'testuser')
    
            post :update_assignments, params: { id: user.id, assignment_ids: [assignment2.id] }
        end

        context 'with invalid parameters' do
            it 'does not update the assignments' do
              allow_any_instance_of(User).to receive(:save).and_return(false)
              post :update_assignments, params: { id: user.id, assignment_ids: [] }
              expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
              expect(response).to render_template(:show)
            end
        end

        context 'when GitHub API raises an error for add collaborator' do
            it 'handles the error and sets a flash alert' do
              user.assignment_ids = [assignment1.id]
              user.save!
      
              allow(@mock_client).to receive(:add_collaborator).and_raise(Octokit::Error.new)
      
              post :update_assignments, params: { id: user.id, assignment_ids: [assignment2.id] }
      
              expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
              expect(response).to render_template(:show)
            end
        end

        context 'when GitHub API raises an error for remove collaborator' do
            it 'handles the error and sets a flash alert' do
              user.assignment_ids = [assignment1.id]
              user.save!
      
              allow(@mock_client).to receive(:remove_collaborator).and_raise(Octokit::Error.new)
      
              post :update_assignments, params: { id: user.id, assignment_ids: [] }
      
              expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
              expect(response).to render_template(:show)
            end
        end
    end






end