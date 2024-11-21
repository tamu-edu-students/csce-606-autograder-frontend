require 'rails_helper'
RSpec.describe TestsController, type: :controller do
  let!(:assignment) { Assignment.create!(assignment_name: 'Assignment 1', repository_name: 'assignment-1') }

  let!(:test_case) do
    assignment.tests.create!(
      name: 'Test 1',
      points: 10,
      test_type: 'unit',
      target: 'target',
      test_block: { code: 'Test code' }
    )
  end

  let(:user) { User.create!(name: 'User', email: 'test@example.com') }

  let(:test_grouping) { create(:test_grouping, assignment: assignment) }
  let(:valid_params) { { points: 10 } }
  let(:invalid_params) { { points: nil } }
  let(:current_user) { create(:user) }
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
      let(:valid_attributes) { { name: 'New Test', points: 20, test_type: 'unit', test_block: { code: 'New test code' }, target: 'target' } }
      it "creates a new test and redirects to the assignment path" do
      expect {
          post :create, params: { assignment_id: assignment.id, test: valid_attributes, format: :html }
      }.to change(Test, :count).by(1)

      expect(response).to redirect_to(assignment_path(assignment))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: '', points: 0, test_type: '', test_block: {} } }
      it "does not create a new test and redirects with error messages" do
      expect {
          post :create, params: { assignment_id: assignment.id, test: invalid_attributes, format: :html }
      }.to_not change(Test, :count)
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(assignment_path(assignment))
      end
    end

    it "update_remote is called" do
      post :create, params: { assignment_id: assignment.id, test: { name: 'New Test', points: 20, test_type: 'unit', test_block: { code: 'New test code' }, target: 'target' }, format: :html }
      expect(controller).to have_received(:update_remote)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: 'Updated Test', points: 15, test_type: 'i_o', test_block: { input_path: 'input.txt', output_path: 'output.txt' } } }

      it "updates the test and redirects to the assignment path" do
        patch :update, params: { assignment_id: assignment.id, id: test_case.id, test: new_attributes, format: :html }
        expect(response).to redirect_to(assignment_path(assignment))
        expect(test_case.reload.name).to eq('Updated Test')
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: '', points: -5, test_type: 'invalid_type', test_block: {} } }

      it "does not update the test and redirects with errors" do
        patch :update, params: { assignment_id: assignment.id, id: test_case.id, test: invalid_attributes, format: :html }
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(assignment_path(assignment))
        expect(test_case.reload.name).not_to eq('')
      end
    end

    it "update_remote is called" do
      patch :update, params: { assignment_id: assignment.id, id: test_case.id,
        test: { name: 'Updated Test', points: 15, test_type: 'i_o', test_block: { input_path: 'input.txt', output_path: 'output.txt' } }, format: :html }
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

  describe 'GET #edit_points' do
    describe 'when all records are found' do
      before do
        allow(Rails.logger).to receive(:debug)
        allow(controller).to receive(:puts)
      end

      it 'assigns the correct instance variables' do
        get :edit_points, params: { assignment_id: assignment.id, test_grouping_id: test_grouping.id, id: test_case.id }, format: :js
        expect(assigns(:assignment)).to eq(assignment)
        expect(assigns(:test_grouping)).to eq(test_grouping)
        expect(assigns(:test)).to eq(test_case)
      end

      it 'responds with JS format' do
        get :edit_points, params: { assignment_id: assignment.id, test_grouping_id: test_grouping.id, id: test_case.id }, format: :js
        expect(response.content_type).to include('text/javascript')
      end
    end

    describe 'when assignment is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :edit_points, params: { assignment_id: 'non_existent', test_grouping_id: test_grouping.id, id: test_case.id }, format: :js
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'when test_grouping is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        test_case = create(:test, test_grouping: create(:test_grouping, assignment: assignment), test_block: { code: 'Test code' }, test_type: 'unit')

        expect {
          get :edit_points, params: { assignment_id: assignment.id, test_grouping_id: 'non_existent', id: test_case.id }, format: :js
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end


    describe 'when test is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :edit_points, params: { assignment_id: assignment.id, test_grouping_id: test_grouping.id, id: 'non_existent' }, format: :js
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'when assignment is nil' do
      before do
        allow(Assignment).to receive(:find).and_return(nil)
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :edit_points, params: { assignment_id: 'non_existent', test_grouping_id: 'any', id: 'any' }, format: :js
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #update_points' do
    before do
      allow(controller).to receive(:current_user_and_token).and_return([ current_user, "auth_token" ])
      allow(controller).to receive(:update_remote)
    end

    describe "with valid parameters" do
      it "updates the test points and redirects to the assignment path for HTML request" do
        patch :update_points, params: { assignment_id: assignment.id, test_grouping_id: test_grouping.id, id: test_case.id, test: valid_params }, format: :html
        test_case.reload

        expect(test_case.points).to eq(10)
        expect(controller).to have_received(:update_remote).with(current_user, "auth_token")
        expect(response).to redirect_to(assignment_path(assignment))
        expect(flash[:notice]).to eq("Test points updated successfully.")
      end

      it "updates the test points and returns success JSON response" do
        patch :update_points, params: { assignment_id: assignment.id, test_grouping_id: test_grouping.id, id: test_case.id, test: valid_params }, format: :json
        test_case.reload

        expect(test_case.points).to eq(10)
        expect(controller).to have_received(:update_remote).with(current_user, "auth_token")
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("success" => true, "points" => 10)
      end
    end

    describe "with invalid parameters" do
      it "does not update the test points and returns an error in JSON format" do
        patch :update_points, params: { assignment_id: assignment.id, test_grouping_id: test_grouping.id, id: test_case.id, test: invalid_params }, format: :json
        test_case.reload

        expect(test_case.points).to eq(10)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(JSON.parse(response.body)["success"]).to be_falsey
      end
    end
  end

  describe "#include_string_to_jsonb" do
  it "returns an empty include array for nil input" do
    result = controller.send(:include_string_to_jsonb, nil)
    expect(result).to eq({ include: [] })
  end

  it "returns an empty include array for empty string input" do
    result = controller.send(:include_string_to_jsonb, "")
    expect(result).to eq({ include: [] })
  end

  it "parses a valid JSON-formatted string into an array" do
    result = controller.send(:include_string_to_jsonb, '["file1.h", "file2.h"]')
    expect(result).to eq({ include: [ "file1.h", "file2.h" ] })
  end

  it "handles invalid JSON and splits the string by commas" do
    result = controller.send(:include_string_to_jsonb, "file1.h, file2.h, file3.h")
    expect(result).to eq({ include: [ "file1.h", "file2.h", "file3.h" ] })
  end

  it "removes empty entries from a comma-separated string" do
    result = controller.send(:include_string_to_jsonb, "file1.h, , file2.h,,file3.h")
    expect(result).to eq({ include: [ "file1.h", "file2.h", "file3.h" ] })
  end
end
end
