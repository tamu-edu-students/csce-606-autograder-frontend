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
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Assignment.create! valid_attributes
      get :index
      expect(response).to be_successful
    end
  end

describe 'GET #show' do
  let(:directory_structure) do
    [
      { name: "test_file.txt", type: "file" }
    ]
  end

  before do
    # Ensure assignment is created before any test groupings
    @assignment = Assignment.create!(valid_attributes)
    @test_grouping_1 = @assignment.test_groupings.create!(name: 'Test Grouping 1')
    @test_grouping_2 = @assignment.test_groupings.create!(name: 'Test Grouping 2')
    @test1 = @assignment.tests.create!(name: 'Test 1', points: 10.0, test_type: 'unit', target: 'target', test_block: { code: 'Test body' }, test_grouping_id: @test_grouping_1.id)
    @test2 = @assignment.tests.create!(name: 'Test 2', points: 20.0, test_type: 'unit', target: 'target', test_block: { code: 'Test body' }, test_grouping_id: @test_grouping_2.id)

    allow_any_instance_of(Assignment).to receive(:fetch_directory_structure).and_return(directory_structure)
  end

  it 'retrieves the directory structure from GitHub and assigns it to @directory_structure' do
    get :show, params: { id: @assignment.to_param }
    expect(assigns(:directory_structure)).to eq(directory_structure)
  end

  it 'assigns the test groupings to @test_groupings including associated tests' do
    get :show, params: { id: @assignment.to_param }
    expect(assigns(:test_groupings)).to include(@test_grouping_1, @test_grouping_2)
    expect(assigns(:test_groupings).flat_map(&:tests)).to include(@test1, @test2)
  end

  it 'returns a success response' do
    get :show, params: { id: @assignment.to_param }
    expect(response).to be_successful
  end

  it 'assigns the correct total points to @total_points' do
    get :show, params: { id: @assignment.to_param }
    expect(assigns(:total_points)).to eq(30.0)
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
      .with("AutograderFrontend/#{assignment.repository_name}", user1.name, permission: 'pull')
      expect(@mock_client).to receive(:add_collaborator)
        .with("AutograderFrontend/#{assignment.repository_name}", user2.name, permission: 'push')
      expect(@mock_client).to receive(:remove_collaborator)
        .with("AutograderFrontend/#{assignment.repository_name}", user3.name)
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

  describe 'GET #create_and_download_zip' do
    let(:assignment) { create(:assignment, repository_name: 'test-repository') }
    let(:base_path) { '/fake/base/path' }
    let(:local_repository_path) { File.join(base_path, assignment.repository_name) }
    let(:original_zip_file) { File.join(local_repository_path, "autograder.zip") }
    let(:new_zip_filename) { "#{assignment.assignment_name}.zip" }
    let(:renamed_zip_path) { File.join(local_repository_path, new_zip_filename) }

    before do
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(assignment).to receive(:local_repository_path).and_return(local_repository_path)
      allow(Dir).to receive(:chdir).with(local_repository_path).and_yield

      # Mock the file existence and rename operations
      allow(File).to receive(:exist?).with(original_zip_file).and_return(true)
      allow(File).to receive(:rename).with(original_zip_file, renamed_zip_path)
      allow(File).to receive(:exist?).with(renamed_zip_path).and_return(true)

      # Mock send_file to avoid ActionController::MissingFile error
      allow(controller).to receive(:send_file).with(renamed_zip_path, type: 'application/zip', disposition: 'attachment', filename: new_zip_filename).and_return(true)
    end
    it 'calls the make command in the assignment local repository path' do
      allow_any_instance_of(AssignmentsController).to receive(:system).with("make").and_return(true)
      get :create_and_download_zip, params: { id: assignment.id }, format: :zip
    end


    it 'renames the autograder.zip file to the assignment name zip' do
      expect(File).to receive(:rename).with(original_zip_file, renamed_zip_path)
      get :create_and_download_zip, params: { id: assignment.id }, format: :zip
    end

    it 'sends the renamed zip file as a download' do
      get :create_and_download_zip, params: { id: assignment.id }, format: :zip
      expect(controller).to have_received(:send_file).with(renamed_zip_path, type: 'application/zip', disposition: 'attachment', filename: new_zip_filename)
    end

    it 'sets a flash notice indicating the download was successful' do
      get :create_and_download_zip, params: { id: assignment.id }, format: :zip
      expect(flash[:notice]).to eq("#{new_zip_filename} downloaded successfully")
    end

    context 'when the ZIP file does not exist' do
      before do
        allow(File).to receive(:exist?).with(renamed_zip_path).and_return(false)
      end

      it 'sets a flash alert indicating that the ZIP file could not be exported' do
        get :create_and_download_zip, params: { id: assignment.id }, format: :zip
        expect(flash[:alert]).to eq('Could not export assignment')
        expect(response).to redirect_to(assignment_path(assignment))
      end
    end
  end

  describe 'POST #upload_file' do
    let(:assignment) { create(:assignment, valid_attributes) }
    let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_file.txt'), 'text/plain') }
    let(:valid_params) { { id: assignment.id, file: file, path: 'tests' } }
    let(:invalid_params) { { id: assignment.id, file: nil, path: nil } }
    let(:github_token) { 'mock_github_token' }

    before do
      allow(controller).to receive(:session).and_return({ github_token: github_token })
    end

    context 'when file upload is successful' do
      before do
        # Update the stub to match ActionDispatch::Http::UploadedFile as argument type
        allow_any_instance_of(Assignment).to receive(:upload_file_to_repo)
          .with(instance_of(ActionDispatch::Http::UploadedFile), 'tests', github_token)
          .and_return(true)
      end

      it 'calls upload_file_to_repo with correct parameters' do
        expect_any_instance_of(Assignment).to receive(:upload_file_to_repo)
          .with(instance_of(ActionDispatch::Http::UploadedFile), 'tests', github_token)
        post :upload_file, params: valid_params
      end

      it 'returns a success response with JSON' do
        post :upload_file, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'success' => true })
      end
    end

    context 'when file upload fails' do
      before do
        allow_any_instance_of(Assignment).to receive(:upload_file_to_repo)
          .with(instance_of(ActionDispatch::Http::UploadedFile), 'tests', github_token)
          .and_return(false)
      end

      it 'returns an error response with JSON' do
        post :upload_file, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'success' => false, 'error' => 'Failed to upload to GitHub' })
      end
    end

    context 'when file or path parameters are missing' do
      let(:invalid_params) { { id: assignment.id, file: nil, path: nil } }  # Ensure `file` is nil

      it 'returns an error response with JSON' do
        post :upload_file, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'success' => false, 'error' => 'Failed to upload to GitHub' })
      end
    end
  end

  describe 'GET #render_test_block_partial' do
    before do
      @test = create(:test, assignment: assignment, test_type: 'unit')
    end

    it 'renders the appropriate partial for a given test type' do
      get :render_test_block_partial, params: { test_type: @test.test_type }
      expect(response).to render_template(partial: "assignments/test_blocks/_unit")
    end

    it 'responds with a success status' do
      get :render_test_block_partial, params: { test_type: 'compile', id: assignment.id }, xhr: true
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #update_order' do
    let!(:test1) { create(:test, assignment: assignment, position: 1, name: 'Test 1', test_block: { code: 'Test code' }, test_type: 'unit') }
    let!(:test2) { create(:test, assignment: assignment, position: 2, name: 'Test 2', test_block: { code: 'Test code' }, test_type: 'unit') }

    it 'updates the positions of tests based on test_ids' do
      post :update_order, params: { assignment_id: assignment.id, test_ids: [ test2.id, test1.id ] }
      expect(test1.reload.position).to eq(2)
      expect(test2.reload.position).to eq(1)
    end

    it 'responds with a success status and JSON message' do
      post :update_order, params: { assignment_id: assignment.id, test_ids: [ test2.id, test1.id ] }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
      expect(JSON.parse(response.body)).to eq("status" => "success")
    end
  end
end
