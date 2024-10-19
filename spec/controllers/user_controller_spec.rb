require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { User.create!(name: 'Test User') }
  let!(:assignment1) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'repo1') }
  let!(:assignment2) { Assignment.create!(assignment_name: 'Assignment 2', repository_name: 'repo2') }
  let!(:assignment3) { Assignment.create!(assignment_name: 'Assignment 3', repository_name: 'repo3') }

  before do
    allow(controller).to receive(:current_user).and_return(user)  # Mock current_user to return a user
    allow(controller).to receive(:session).and_return({ user_id: user.id, github_token: "fake_token" })  # Mock the session

    # allow(controller).to receive(:session).and_return({ github_token: 'fake_token' })
    @mock_client = instance_double(Octokit::Client)
    allow(Octokit::Client).to receive(:new).and_return(@mock_client)
  end

  describe "when all the users in the organization are displayed" do
    it "assigns users" do
      get :index
      expect(assigns(:users)).to eq([ user ])
    end
  end

  describe "when the assignments are shown for each user" do
    it 'assigns @user' do
      get :show, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns @assignments' do
      assignment = Assignment.create!(assignment_name: 'Test Assignment', repository_name: 'TestAssignment')
      get :show, params: { id: user.id }
      expect(assigns(:assignments)).to include(assignment)
    end
  end

  describe "when the assignment access for a user is updated" do
    it 'updates the assignments' do
      allow(controller).to receive(:update_github_permissions).and_return(true)
      post :update_assignments, params: {
        id: user.id,
        read_assignment_ids: [ assignment1.id ],
        write_assignment_ids: [ assignment2.id ]
      }

      expect(Permission.find_by(user: user, assignment: assignment1).role).to eq("read")
      expect(Permission.find_by(user: user, assignment: assignment2).role).to eq("read_write")
      expect(Permission.find_by(user: user, assignment: assignment3).role).to eq("no_permission")
      expect(flash[:notice]).to eq('Assignments updated successfully.')
    end

    it 'redirects to the users index' do
      allow(controller).to receive(:update_github_permissions).and_return(true)
      post :update_assignments, params: { id: user.id, read_assignment_ids: [ assignment1.id ] }
      expect(response).to redirect_to(users_path)
    end

    it 'updates GitHub permissions correctly' do
      expect(@mock_client).to receive(:add_collaborator).with('AutograderFrontend/repo2', user.name, permission: 'push')
      expect(@mock_client).to receive(:add_collaborator).with('AutograderFrontend/repo1', user.name, permission: 'pull')
      expect(@mock_client).to receive(:remove_collaborator).with('AutograderFrontend/repo3', user.name)

      post :update_assignments, params: { id: user.id, write_assignment_ids: [ assignment2.id ], read_assignment_ids: [ assignment1.id ] }
    end
  end

  describe 'Assignment updated with invalid parameters' do
    it 'does not update the assignments' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post :update_assignments, params: { id: user.id, read_assignment_ids: [], write_assignment_ids: [] }
      expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
      expect(response).to render_template(:show)
    end
  end

  describe 'GitHub API raises an error for add_collaborator' do
    it 'handles the error and sets a flash alert' do
      allow(@mock_client).to receive(:add_collaborator).and_raise(Octokit::Error.new)

      post :update_assignments, params: { id: user.id, read_assignment_ids: [ assignment1.id, assignment2.id, assignment3.id ], write_assignment_ids: [] }

      expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
      expect(response).to render_template(:show)
    end
  end

  describe 'GitHub API raises an error for remove_collaborator' do
    it 'handles the error and sets a flash alert' do
      allow(@mock_client).to receive(:add_collaborator).and_return(true)
      allow(@mock_client).to receive(:remove_collaborator).and_raise(Octokit::Error.new)

      post :update_assignments, params: { id: user.id, read_assignment_ids: [], write_assignment_ids: [ assignment1.id ] }

      expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
      expect(response).to render_template(:show)
    end
  end

  describe 'GitHub API raises an error for unknown permission role' do
    it 'logs an error' do
      allow(controller).to receive(:session).and_return({ github_token: 'fake_token' })
      allow(@mock_client).to receive(:add_collaborator).and_return(true)
      allow(@mock_client).to receive(:remove_collaborator).and_return(true)
      allow(Rails.logger).to receive(:error)

      Permission.create!(user: user, assignment: assignment1, role: 'unknown_role')
      Permission.create!(user: user, assignment: assignment2, role: 'read')
      Permission.create!(user: user, assignment: assignment3, role: 'read')

      controller.send(:update_github_permissions, user)
      expected_error_message = "Unknown permission role: unknown_role for user Test User on assignment 1"
      expect(Rails.logger).to have_received(:error).with(expected_error_message)
    end
  end
end
