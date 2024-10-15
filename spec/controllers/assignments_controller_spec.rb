require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do
  let(:valid_attributes) do
    {
      assignment_name: 'Test Assignment',
      repository_name: 'test-repository-1'
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
    let(:assignment) {Assignment.create! valid_attributes}
    let(:assignment2) {Assignment.create!(repository_name: 'test-repository-2', assignment_name: 'Test Assignment 2')}

    it 'returns all the assignments when no matching query is provided' do
      get :index
      expect(assigns(:assignments)).to eq([assignment, assignment2])
    end

    it 'returns matching assignments when a matching query is provided and match is successful' do
      get :index, params: { query: 'repository-1' }
      expect(assigns(:assignments)).to eq([assignment])
    end

    describe 'when a matching query is provided and match is unsuccessful' do
      it 'returns no assignment' do
        get :index, params: { query: 'Nonexistent' }
        expect(assigns(:assignments)).to be_empty
      end
      it 'sets a flash alert' do
        get :index, params: { query: 'Nonexistent' }
        expect(flash.now[:alert]).to eq('No matching assignments found')
      end
    end
  end

  describe 'GET #show' do
    let(:assignment) {Assignment.create! valid_attributes}
    
    it 'redirects to the index action with the query when query param is present' do
      get :show, params: { id: assignment.to_param, query: 'test' }
      expect(response).to redirect_to(assignments_path(query: 'test'))
    end

    describe 'when query param is not present' do
      it 'yields a successful response' do
        get :show, params: { id: assignment.to_param }

        # Check that the response is not a redirect to index
        expect(response).to be_successful
      end
      it 'renders the show template' do
        get :show, params: { id: assignment.to_param }

        # Check that the response is not a redirect to index
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    let(:assignment) {Assignment.create! valid_attributes}
      
    it 'redirects to the index action with the query when query param is present' do
      get :edit, params: { id: assignment.to_param, query: 'test' }
      expect(response).to redirect_to(assignments_path(query: 'test'))
    end

    describe 'when query param is not present' do
      it 'yields a successful response' do
        get :edit, params: { id: assignment.to_param }

        # Check that the response is not a redirect to index
        expect(response).to be_successful
      end
      it 'renders the edit template' do
        get :edit, params: { id: assignment.to_param }

        # Check that the response is not a redirect to index
        expect(response).to render_template(:edit)
      end
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
      
    it 'redirects to the index action with the query when query param is present' do
      get :update, params: { id: assignment.to_param, assignment: new_attributes, query: 'test' }
      expect(response).to redirect_to(assignments_path(query: 'test'))
    end

    describe 'when query param is not present and we update with valid parameters' do
      before do
        allow(controller).to receive(:session).and_return({ user_id: user.id, github_token: auth_token })
        allow(User).to receive(:find).with(user.id).and_return(user)
      end

      it 'does not redirect to the index' do
        get :update, params: { id: assignment.to_param, assignment: new_attributes }

        # Check that the response is not a redirect to index
        expect(response).not_to redirect_to(assignments_path)
      end
      it 'redirects to the assignment show page' do
        get :update, params: { id: assignment.to_param, assignment: new_attributes }

        # Check that the response is not a redirect to index
        expect(response).to redirect_to(assignment_path(assignment))
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

    describe 'when query param is not present and we update with invalid parameters' do
      it 'renders the edit template' do
        put :update, params: { id: assignment.to_param, assignment: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:assignment) { Assignment.create! valid_attributes }

    it 'redirects to the index action with the query when query param is present' do
      get :destroy, params: { id: assignment.to_param, query: 'test' }
      expect(response).to redirect_to(assignments_path(query: 'test'))
    end

    describe 'when query param is not present' do
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
end
