require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do
  let(:valid_attributes) do
    {
      assignment_name: 'Test Assignment',
      repository_name: 'test-repository'
    }
  end

  let(:invalid_attributes) do
    {
      assignment_name: nil,
      repository_name: nil
    }
  end

  let(:mock_github_token) { 'mock_github_token' }
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }

  let!(:assignment) { create(:assignment) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let(:client) { instance_double(Octokit::Client) }

  before do
    allow(controller).to receive(:require_login).and_return(true)
    # allow(controller).to receive(:session).and_return({ github_token: mock_github_token })
    allow(controller).to receive(:current_user).and_return(user)  # Mock current_user to return a user
    allow(controller).to receive(:session).and_return({ user_id: user.id, github_token: mock_github_token })  # Mock the session
    @mock_client = instance_double(Octokit::Client)
    allow(Octokit::Client).to receive(:new).and_return(@mock_client)
    @mock_client = instance_double(Octokit::Client)
    allow(Octokit::Client).to receive(:new).and_return(@mock_client)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Assignment.create! valid_attributes
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      assignment = Assignment.create! valid_attributes
      get :show, params: { id: assignment.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      assignment = Assignment.create! valid_attributes
      get :edit, params: { id: assignment.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    before do
      allow_any_instance_of(Assignment).to receive(:assignment_repo_init).and_return(true)
    end
    context 'with valid parameters' do
      it 'creates a new Assignment' do
        expect do
          post :create, params: { assignment: valid_attributes }
        end.to change(Assignment, :count).by(1)
      end

      it 'calls assignment_repo_init' do
        assignment = Assignment.new(valid_attributes)
        expect(assignment).to receive(:assignment_repo_init).with(mock_github_token)
        allow(Assignment).to receive(:new).and_return(assignment)
        post :create, params: { assignment: valid_attributes }
      end

      it 'redirects to the created assignment' do
        post :create, params: { assignment: valid_attributes }
        expect(response).to redirect_to(Assignment.last)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Assignment' do
        expect do
          post :create, params: { assignment: invalid_attributes }
        end.to change(Assignment, :count).by(0)
      end

      it 'renders the new template' do
        post :create, params: { assignment: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:assignment) { Assignment.create! valid_attributes }
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:auth_token) { 'mock_github_token' }
    let(:new_attributes) do { repository_name: 'updated-repository' } end

    describe 'with valid parameters' do
      before do
        allow(controller).to receive(:session).and_return({ user_id: user.id, github_token: auth_token })
        allow(User).to receive(:find).with(user.id).and_return(user)
      end
      it 'updates the requested assignment' do
        put :update, params: { id: assignment.to_param, assignment: new_attributes }
        assignment.reload
        expect(assignment.repository_name).to eq('updated-repository')
      end

      it 'redirects to the assignment' do
        put :update, params: { id: assignment.to_param, assignment: new_attributes }
        expect(response).to redirect_to(assignment)
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template' do
        put :update, params: { id: assignment.to_param, assignment: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:assignment) { Assignment.create! valid_attributes }

    it 'destroys the requested assignment' do
      expect do
        delete :destroy, params: { id: assignment.to_param }
      end.to change(Assignment, :count).by(-1)
    end

    it 'redirects to the assignments list' do
      delete :destroy, params: { id: assignment.to_param }
      expect(response).to redirect_to(assignments_path)
    end
  end

  describe 'GET #search' do
    let!(:assignment1) { Assignment.create!(repository_name: 'test-repository-1', assignment_name: 'Test Assignment 1') }
    let!(:assignment2) { Assignment.create!(repository_name: 'test-repository-2', assignment_name: 'Test Assignment 2') }

    describe 'when query is present and there is a match' do
      it 'renders the index template' do
        get :search, params: { query: 'test-repository-1' }
        expect(response).to render_template(:index)
      end
      it 'shows only the matching assignments in the rendered view' do
        get :search, params: { query: 'test-repository-1' }
        expect(assigns(:assignments)).to eq([ assignment1 ])
      end
    end

    describe 'when query is present and there is no match' do
      it 'renders the index template' do
        get :search, params: { query: 'Nonexistent' }
        expect(response).to render_template(:index)
      end
      it 'shows all the assignments in the rendered view' do
        allow(Assignment).to receive(:all).and_return(Assignment.where(id: [ assignment1.id, assignment2.id ]))
        get :search, params: { query: 'Nonexistent' }
        expect(assigns(:assignments)).to eq([ assignment1, assignment2 ])  # Redirects to show all assignments
      end
      it 'shows a flash alert in the rendered view' do
        get :search, params: { query: 'Nonexistent' }
        expect(flash.now[:alert]).to eq('No matching assignments found')
      end
    end

    describe 'when query is not present' do
      it 'redirects to the default index view path' do
        get :search
        expect(response).to redirect_to(assignments_path)
      end
    end
  end

  describe 'GET #users' do
    before do
      User.delete_all
      allow(controller).to receive(:params).and_return({ id: assignment.id })
    end

    let!(:users) { create_list(:user, 3) }
    let!(:assignment) { create(:assignment) }

    it 'retrieves all users and assigns them to @users' do
      get :users, params: { id: assignment.id }
      expect(assigns(:users).pluck(:id)).to match_array(users.pluck(:id))
    end

    it 'finds the assignment by id and assigns it to @assignment' do
      get :users, params: { id: assignment.id }

      expect(assigns(:assignment)).to eq(assignment)
    end
  end

  describe 'update assignment permission with valid arguments' do
    let(:valid_params) do
      {
        id: assignment.id,
        read_user_ids: [ user1.id.to_s ],
        write_user_ids: [ user2.id.to_s ]
      }
    end

    it 'updates user permissions' do
      allow(controller).to receive(:update_github_permissions).and_return(true)
      post :update_users, params: valid_params
      expect(Permission.find_by(user: user1, assignment: assignment).role).to eq('read')
      expect(Permission.find_by(user: user2, assignment: assignment).role).to eq('read_write')
      expect(Permission.find_by(user: user3, assignment: assignment).role).to eq('no_permission')
    end

    it 'updates Github permissions' do
      allow(User).to receive(:all).and_return(User.where(id: [ user1.id, user2.id, user3.id ]))
      expect(@mock_client).to receive(:add_collaborator)
      .with('AutograderFrontend/test-assignment', user1.name, permission: 'pull')
      expect(@mock_client).to receive(:add_collaborator)
        .with('AutograderFrontend/test-assignment', user2.name, permission: 'push')
      expect(@mock_client).to receive(:remove_collaborator)
        .with('AutograderFrontend/test-assignment', user3.name)
      post :update_users, params: valid_params
    end
  end

  describe 'when assignment save fails' do
      before do
        allow_any_instance_of(Assignment).to receive(:save).and_return(false)
      end

      it 'renders show template with error message' do
        post :update_users, params: { id: assignment.id }

        expect(response).to render_template(:show)
        expect(flash[:alert]).to include('Failed to update assignments')
      end
  end

  describe 'when GitHub update fails' do
    before do
      allow(controller).to receive(:update_github_permissions).and_raise(Octokit::Error)
    end

    it 'renders show template with error message' do
      post :update_users, params: { id: assignment.id }

      expect(response).to render_template(:show)
      expect(flash[:alert]).to include('Failed to update assignments')
    end

    it 'logs the error' do
      expect(Rails.logger).to receive(:error).with(/Failed to update GitHub permissions/)
      post :update_users, params: { id: assignment.id }
    end
  end

  describe 'GitHub API raises an error for add_collaborator' do
    let(:valid_params) do
      {
        id: assignment.id,
        read_user_ids: [ user1.id.to_s ],
        write_user_ids: [ user2.id.to_s ]
      }
    end
    it 'handles the error and sets a flash alert' do
      allow(@mock_client).to receive(:add_collaborator).and_raise(Octokit::Error.new)

      post :update_users, params: valid_params
      expect(flash[:alert]).to eq('Failed to update assignments. Please try again.')
      expect(response).to render_template(:show)
    end
  end

  describe 'GitHub API raises an error for remove_collaborator' do
    let(:valid_params) do
      {
        id: assignment.id,
        read_user_ids: [ user1.id.to_s ],
        write_user_ids: [ user2.id.to_s ]
      }
    end
    it 'handles the error and sets a flash alert' do
      allow(@mock_client).to receive(:add_collaborator).and_return(true)
      allow(@mock_client).to receive(:remove_collaborator).and_raise(Octokit::Error.new)

      post :update_users, params: valid_params

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
      allow(User).to receive(:all).and_return(User.where(id: [ user1.id, user2.id, user3.id ]))

      Permission.create!(user: user1, assignment: assignment, role: 'unknown_role')
      Permission.create!(user: user2, assignment: assignment, role: 'read')
      Permission.create!(user: user3, assignment: assignment, role: 'read_write')

      controller.send(:update_github_permissions, assignment)
      expected_error_message = "Unknown permission role: unknown_role for user #{user1.name}"
      expect(Rails.logger).to have_received(:error).with(expected_error_message)
    end
  end
end
