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

  before do
    allow(controller).to receive(:session).and_return({ github_token: mock_github_token })
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
    let(:new_attributes) do { assignment_name: 'Updated Assignment' } end

    describe 'with valid parameters' do
      before do
        allow(controller).to receive(:session).and_return({ user_id: user.id, github_token: auth_token })
        allow(User).to receive(:find).with(user.id).and_return(user)
      end
      it 'updates the requested assignment' do
        put :update, params: { id: assignment.to_param, assignment: new_attributes }
        assignment.reload
        expect(assignment.assignment_name).to eq('Updated Assignment')
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
end
