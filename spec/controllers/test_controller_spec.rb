require 'rails_helper'
RSpec.describe TestsController, type: :controller do
  let!(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'assignment-1') }

  let!(:test_case) { assignment.tests.create!(name: 'Test 1', points: 10, test_type: 'unit', target: 'target', actual_test: 'Test code') }

  let(:user) { User.create!(name: 'User', email: 'test@example.com') }
  # Mock authentication helper methods
  before do
    allow(controller).to receive(:current_user_and_token).and_return([ double("User"), "mock_auth_token" ])
    allow(controller).to receive(:update_remote)

    allow(controller).to receive(:current_user).and_return(user)  # Mock current_user to return a user
    allow(controller).to receive(:session).and_return({ user_id: user.id, github_token: "mock_auth_token" })
  end

  describe "GET #index" do
    it "assigns @tests and renders the index template" do
      get :index, params: { assignment_id: assignment.id }
      expect(assigns(:tests)).to eq([ test_case ])
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "assigns @test and renders the show template" do
      get :show, params: { assignment_id: assignment.id, id: test_case.id }
      expect(assigns(:test)).to eq(test_case)
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    it "assigns a new @test and renders the new template" do
      get :new, params: { assignment_id: assignment.id }
      expect(assigns(:test)).to be_a_new(Test)
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "assigns @test and renders the edit template" do
      get :edit, params: { assignment_id: assignment.id, id: test_case.id }
      expect(assigns(:test)).to eq(test_case)
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: 'New Test', points: 20, test_type: 'unit', actual_test: 'New test code', target: 'target' } }
      it "creates a new test and redirects to the assignment path" do
      expect {
          post :create, params: { assignment_id: assignment.id, test: valid_attributes, format: :html }
      }.to change(Test, :count).by(1)

      expect(response).to redirect_to(assignment_path(assignment))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: '', points: 0, test_type: '', actual_test: '' } }
      it "does not create a new test and redirects with error messages" do
      expect {
          post :create, params: { assignment_id: assignment.id, test: invalid_attributes, format: :html }
      }.to_not change(Test, :count)
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(assignment_path(assignment))
      end
    end

    it "update_remote is called" do
      post :create, params: { assignment_id: assignment.id, test: { name: 'New Test', points: 20, test_type: 'unit', actual_test: 'New test code', target: 'target' }, format: :html }
      expect(controller).to have_received(:update_remote)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: 'Updated Test', points: 15, test_type: 'i/o', actual_test: 'Updated code' } }

      it "updates the test and redirects to the assignment path" do
        patch :update, params: { assignment_id: assignment.id, id: test_case.id, test: new_attributes, format: :html }
        expect(response).to redirect_to(assignment_path(assignment))
        expect(test_case.reload.name).to eq('Updated Test')
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: '', points: -5, test_type: 'invalid_type', actual_test: '' } }

      it "does not update the test and redirects with errors" do
        patch :update, params: { assignment_id: assignment.id, id: test_case.id, test: invalid_attributes, format: :html }
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(assignment_path(assignment))
        expect(test_case.reload.name).not_to eq('')
      end
    end

    it "update_remote is called" do
      patch :update, params: { assignment_id: assignment.id, id: test_case.id, test: { name: 'Updated Test', points: 15, test_type: 'i/o', actual_test: 'Updated code' }, format: :html }
      expect(controller).to have_received(:update_remote)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the test and redirects to the assignment path" do
      expect {
        delete :destroy, params: { assignment_id: assignment.id, id: test_case.id }
      }.to change(Test, :count).by(-1)
      expect(response).to redirect_to(assignment_path(assignment))
      expect(flash[:notice]).to eq("Test was successfully destroyed.")
    end

    it "update_remote is called" do
      delete :destroy, params: { assignment_id: assignment.id, id: test_case.id }
      expect(controller).to have_received(:update_remote)
    end
  end
end
