require 'rails_helper'

RSpec.describe 'Tests Routes', type: :request do
  let(:assignment) { Assignment.create!(assignment_name: 'Assignment 1') }
  let(:test_case) { assignment.tests.create!(name: 'Test 1', points: 10, test_type: 'unit', target: 'target', actual_test: 'some test') }

  describe 'GET /assignments/:assignment_id/tests' do
    it 'routes to tests#index' do
      get "/assignments/#{assignment.id}/tests"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /assignments/:assignment_id/tests/new' do
    it 'routes to tests#new' do
      get "/assignments/#{assignment.id}/tests/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /assignments/:assignment_id/tests' do
    it 'routes to tests#create' do
      post "/assignments/#{assignment.id}/tests", params: { test: { name: 'Test 2', points: 15, test_type: 'compile', actual_test: 'some test code' } }
      expect(response).to have_http_status(:found) # Redirect after successful creation
    end
  end

  describe 'GET /assignments/:assignment_id/tests/:id' do
    it 'routes to tests#show' do
      get "/assignments/#{assignment.id}/tests/#{test_case.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /assignments/:assignment_id/tests/:id/edit' do
    it 'routes to tests#edit' do
      get "/assignments/#{assignment.id}/tests/#{test_case.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /assignments/:assignment_id/tests/:id' do
    it 'routes to tests#update' do
      patch "/assignments/#{assignment.id}/tests/#{test_case.id}", params: { test: { name: 'Updated Test Name' } }
      expect(response).to have_http_status(:found) # Redirect after update
    end
  end

  describe 'DELETE /assignments/:assignment_id/tests/:id' do
    it 'routes to tests#destroy' do
      delete "/assignments/#{assignment.id}/tests/#{test_case.id}"
      expect(response).to have_http_status(:see_other) # Expect 303 status after deletion
    end
  end


  describe 'GET /assignments/:id/create_and_download_zip' do
    it 'routes to assignments#create_and_download_zip' do
      get "/assignments/#{assignment.id}/create_and_download_zip"
      expect(response).to have_http_status(:ok)
    end
  end
end
