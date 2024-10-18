require 'rails_helper'

RSpec.describe TestGroupingsController, type: :controller do
  let!(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'assignment-1') }
  let!(:test_grouping) { assignment.test_groupings.create!(name: 'name') }

  describe 'GET #index' do
    it 'assigns all test groupings as @test_groupings' do
      get :index, params: { assignment_id: assignment.id, format: :json }
      expect(assigns(:test_groupings)).to include(test_grouping)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested test grouping as @test_grouping' do
      get :show, params: { assignment_id: assignment.id, id: test_grouping.id, format: :json }
      expect(assigns(:test_grouping)).to eq(test_grouping)
    end
  end

  describe 'GET #new' do
    it 'assigns a new test grouping as @test_grouping' do
      get :new, params: { assignment_id: assignment.id, format: :json }
      expect(assigns(:test_grouping)).to be_a_new(TestGrouping)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
        it 'creates a new TestGrouping' do
        expect {
            post :create, params: { assignment_id: assignment.id, test_grouping: { name: 'New Test Group' }, format: :json }
        }.to change(TestGrouping, :count).by(1)
        end

        it 'returns a 201 Created status after creation' do
        post :create, params: { assignment_id: assignment.id, test_grouping: { name: 'New Test Group' }, format: :json }
        expect(response).to have_http_status(:created)
        expect(response.body).to include('New Test Group')  # Optional: Check the response body for confirmation
        end
    end



    context 'with invalid params' do
      it 'does not create a new TestGrouping' do
        expect {
          post :create, params: { assignment_id: assignment.id, test_grouping: { name: nil }, format: :json }
        }.not_to change(TestGrouping, :count)
      end

      it 'returns a 422 Unprocessable Entity status' do
        post :create, params: { assignment_id: assignment.id, test_grouping: { name: nil }, format: :json }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Test grouping name can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested test grouping' do
      test_grouping_to_delete = assignment.test_groupings.create!(name: 'Another Test Group')
      expect {
        delete :destroy, params: { assignment_id: assignment.id, id: test_grouping_to_delete.id, format: :json }
      }.to change(TestGrouping, :count).by(-1)
    end

    it 'returns a 204 No Content status after deletion' do
      delete :destroy, params: { assignment_id: assignment.id, id: test_grouping.id, format: :json }
      expect(response).to have_http_status(:no_content)
    end
  end
end
