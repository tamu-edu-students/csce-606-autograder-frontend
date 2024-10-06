require 'rails_helper'

RSpec.describe "AssignmentsController", type: :request do
  let!(:assignment) { Assignment.create!(assignment_name: "Assignment 1") }
  let(:git_folder) { '/Users/walkerjames/Autograded_frontend_new/test_app' }
  let(:original_zip_file) { File.join(git_folder, 'autograder.zip') }
  let(:zip_file_path) { File.join(git_folder, "#{assignment.assignment_name}.zip") }

  before do
    # Stub the system call to avoid actually running it
    allow_any_instance_of(Object).to receive(:system).and_return(true)
  end

  describe "GET /assignments/:id/create_and_download_zip" do
    context "when the operation is successful" do
      before do
        # Stub File.exist? to return true, simulating successful file creation
        allow(File).to receive(:exist?).and_return(true)
        # Stub File.rename to avoid actual file renaming
        allow(File).to receive(:rename).and_return(true)
      end

      it "displays a success message" do
        get create_and_download_zip_assignment_path(assignment)

        # Check for a 200 OK response (since `send_file` typically results in a 200 OK)
        expect(response).to have_http_status(:ok)

        # Check for the success message on the page
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to eq("#{assignment.assignment_name}.zip downloaded successfully")
      end
    end

    context "when the operation fails" do
      before do
        # Stub File.exist? to return false, simulating file creation failure
        allow(File).to receive(:exist?).and_return(false)
      end

      it "displays an error message" do
        get create_and_download_zip_assignment_path(assignment)

        # Check for redirection to the assignment page with the error
        expect(response).to redirect_to(assignment_path(assignment))
        follow_redirect!

        # Check for the error message
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to eq("ZIP file not found. Please ensure the make command works correctly.")
      end
    end
  end
end
