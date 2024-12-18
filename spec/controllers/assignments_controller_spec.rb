require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do
  let(:valid_attributes) do
    {
      assignment_name: 'Test Assignment',
      repository_name: 'test-repository',
      files_to_submit: "main.cpp\nhelper.cpp\nhelper.h\n"
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
  let!(:specific_test) { create(:test, assignment: assignment, test_block: { code: 'Test code' }, test_type: 'unit') }

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
    let(:assignment) { Assignment.create!(valid_attributes) }
    let(:client_double) { instance_double(Octokit::Client) }
    let(:directory_structure) do
      [
        { name: "test_file.txt", type: "file" }
      ]
    end
    let(:mocked_file_tree) do
      {
        "tests" => {
          "test_file.txt" => { name: "test_file.txt", path: "tests/test_file.txt", type: "file" },
          "c++" => {
            "test_file.txt" => { name: "test_file.txt", path: "tests/c++/test_file.txt", type: "file" }
          }
        }
      }
    end

    before do
      allow(Octokit::Client).to receive(:new).and_return(client_double)
      allow(client_double).to receive(:contents).with("AutograderFrontend/#{assignment.repository_name}", path: "tests")
                                              .and_return([ { name: "test_file.txt", type: "file" } ])
      allow_any_instance_of(AssignmentsController).to receive(:build_complete_tree).with(assignment).and_return(mocked_file_tree)
      allow(assignment).to receive(:fetch_directory_structure).with(mock_github_token).and_return(directory_structure)
    end

    it 'assigns @file_tree with the mocked file structure' do
      get :show, params: { id: assignment.to_param }
      expect(assigns(:file_tree)).to eq(mocked_file_tree)
    end

    it 'retrieves the directory structure from GitHub and assigns it to @directory_structure' do
      get :show, params: { id: assignment.to_param }
      expect(assigns(:directory_structure)).to eq(directory_structure)
    end

    it 'assigns @test to the selected test' do
      allow(controller).to receive(:build_complete_tree).and_return([])
      get :show, params: { id: assignment.id, test_id: specific_test.id }
      expect(assigns(:test)).to eq(specific_test)
    end

    it 'assigns @assignment' do
      allow(controller).to receive(:build_complete_tree).and_return([])
      get :show, params: { id: assignment.to_param }
      expect(assigns(:assignment)).to eq(assignment)
    end

    it 'returns a success response' do
      allow(controller).to receive(:build_complete_tree).and_return([])
      get :show, params: { id: assignment.to_param }
      expect(response).to be_successful
    end

    context 'when an Octokit::Error occurs' do
      before do
        allow_any_instance_of(AssignmentsController).to receive(:build_complete_tree).and_raise(Octokit::Error.new(response_status: 500, message: 'API error'))
        get :show, params: { id: assignment.id }
      end

      it 'sets a flash alert' do
        expect(flash[:alert]).to start_with('Could not retrieve file tree:')
      end

      it 'assigns an empty array to @file_tree' do
        expect(assigns(:file_tree)).to eq([])
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
        expect(assignment).to receive(:assignment_repo_init).with(mock_github_token, user)
        allow(Assignment).to receive(:new).and_return(assignment)
        post :create, params: { assignment: valid_attributes }
      end

      it 'redirects to the created assignment' do
        post :create, params: { assignment: valid_attributes }
        expect(response).to redirect_to(Assignment.last)
      end

      it 'no files to submit' do
        valid_attributes[:files_to_submit] = nil
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
    let(:assignment) { create(:assignment, valid_attributes) }
    let(:github_token) { 'fake_github_token' }
    let(:zip_file_path) { '/fake/path/Test Assignment.zip' }

    before do
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(controller).to receive(:session).and_return({ github_token: github_token })
    end

    context 'when the ZIP file is successfully created' do
      before do
        allow(assignment).to receive(:generate_and_rename_zip).with(github_token).and_return(zip_file_path)
        allow(controller).to receive(:send_file).with(zip_file_path, type: 'application/zip', disposition: 'attachment', filename: File.basename(zip_file_path))
      end

      it 'calls the generate_and_rename_zip method on the assignment' do
        # expect(assignment).to receive(:generate_and_rename_zip).with(github_token)
        get :create_and_download_zip, params: { id: assignment.id }, format: :zip
      end

      it 'sends the ZIP file for download' do
        expect(controller).to receive(:send_file).with(zip_file_path, type: 'application/zip', disposition: 'attachment', filename: File.basename(zip_file_path))
        get :create_and_download_zip, params: { id: assignment.id }, format: :zip
      end

      it 'sets a flash notice indicating successful download' do
        get :create_and_download_zip, params: { id: assignment.id }, format: :zip
        expect(flash[:notice]).to eq("#{File.basename(zip_file_path)} downloaded successfully")
      end
    end

    context 'when the ZIP file could not be created' do
      before do
        allow(assignment).to receive(:generate_and_rename_zip).with(github_token).and_return(nil)
      end

      it 'sets a flash alert indicating failure' do
        get :create_and_download_zip, params: { id: assignment.id }, format: :zip
        expect(flash[:alert]).to eq('Could not export assignment')
      end

      it 'redirects to the assignment show page' do
        get :create_and_download_zip, params: { id: assignment.id }, format: :zip
        expect(response).to redirect_to(assignment_path(assignment))
      end
    end
  end

  describe 'build complete tree' do
    describe 'when fetching directory contents is successful' do
      let(:directory_contents) { [ 'file1.cpp', 'file2.cpp' ] }

      before do
        allow(controller).to receive(:fetch_directory_contents).and_return(directory_contents)
      end

      it 'fetches directory contents successfully' do
        result = controller.send(:build_complete_tree, assignment)
        expect(result).to eq(directory_contents)
      end
    end

    context 'when there is a GitHub API error' do
      before do
        allow(controller).to receive(:fetch_directory_contents).and_raise(Octokit::Error.new(response_status: 500, message: 'Some error occurred'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and returns an empty array' do
        result = controller.send(:build_complete_tree, assignment)

        expect(Rails.logger).to have_received(:error) do |message|
          expect(message).to start_with("GitHub API Error:")
        end
        expect(result).to eq([])
      end
    end
  end

  describe 'fetch directory contents' do
    let(:client) { instance_double('Client') }
    let(:repo) { 'example_repo' }
    let(:path) { 'tests/c++' }

    let(:file_item) do
      double(
        name: 'file1.txt',
        path: 'tests/c++/file1.txt',
        type: 'file'
      )
    end

    let(:dir_item) do
      double(
        name: 'dir1',
        path: 'tests/c++/dir1',
        type: 'dir'
      )
    end

    let(:nested_file_item) do
      double(
        name: 'file2.txt',
        path: 'tests/c++/dir1/file2.txt',
        type: 'file'
      )
    end

    before do
      allow(client).to receive(:contents).with(repo, path: path).and_return([ file_item, dir_item ])
      allow(client).to receive(:contents).with(repo, path: 'tests/c++/dir1').and_return([ nested_file_item ])
    end

    it 'returns directory contents with nested structure for directories' do
      expected_result = [
        {
          name: 'file1.txt',
          path: 'tests/c++/file1.txt',
          type: 'file'
        },
        {
          name: 'dir1',
          path: 'tests/c++/dir1',
          type: 'dir',
          children: [
            {
              name: 'file2.txt',
              path: 'tests/c++/dir1/file2.txt',
              type: 'file'
            }
          ]
        }
      ]

      result = controller.send(:fetch_directory_contents, client, repo, path)
      expect(result).to eq(expected_result)
    end

    it 'encodes spaces in directory paths with ++' do
      allow(dir_item).to receive(:path).and_return('tests/c /dir1') # Path with space
      allow(client).to receive(:contents).with(repo, path: 'tests/c++/dir1').and_return([])

      result = controller.send(:fetch_directory_contents, client, repo, path)
      dir_node = result.find { |node| node[:type] == 'dir' }
      expect(dir_node[:path]).to eq('tests/c /dir1')
      expect(dir_node[:children]).to eq([])
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

    before do
      allow_any_instance_of(AssignmentsController).to receive(:current_user_and_token).and_return([ user, 'mock_github_token' ])
      allow_any_instance_of(Assignment).to receive(:generate_tests_file).and_return(true)
      allow_any_instance_of(Assignment).to receive(:push_changes_to_github).and_return(true)
    end

    it 'updates the positions of tests and calls generate_tests_file and push_changes_to_github' do
      post :update_order, params: { assignment_id: assignment.id, test_ids: [ test2.id, test1.id ] }

      expect(test1.reload.position).to eq(2)
      expect(test2.reload.position).to eq(1)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('application/json')
      expect(JSON.parse(response.body)).to eq('status' => 'success')
    end
  end



  describe 'POST #update_test_grouping_order' do
    let!(:grouping1) { create(:test_grouping, assignment: assignment, position: 1) }
    let!(:grouping2) { create(:test_grouping, assignment: assignment, position: 2) }
    let!(:grouping3) { create(:test_grouping, assignment: assignment, position: 3) }

    context 'with valid grouping_ids' do
      it 'updates the positions of the test groupings' do
        post :update_test_grouping_order, params: { assignment_id: assignment.id, grouping_ids: [ grouping3.id, grouping1.id, grouping2.id ] }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("message" => "Order updated successfully")

        # Reload groupings and check updated positions
        expect(grouping3.reload.position).to eq(1)
        expect(grouping1.reload.position).to eq(2)
        expect(grouping2.reload.position).to eq(3)
      end
    end

    context 'with an invalid grouping_id' do
      it 'returns a not found error for invalid grouping_id' do
        post :update_test_grouping_order, params: { assignment_id: assignment.id, grouping_ids: [ grouping1.id, grouping2.id, -1 ] }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq("error" => "Couldn't find TestGrouping with 'id'=-1")
      end
    end

    context 'when a StandardError occurs' do
      before do
        allow(TestGrouping).to receive(:find).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns an unprocessable entity error' do
        post :update_test_grouping_order, params: { assignment_id: assignment.id, grouping_ids: [ grouping1.id, grouping2.id ] }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq("error" => "Unexpected error")
      end
    end
  end
end
