class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[ show edit update destroy ]

  # GET /assignments or /assignments.json
  def index
    @assignments = Assignment.all
  end

  def show
    @assignment = Assignment.find(params[:id])
    @tests = @assignment.tests
    @test = Test.find(params[:test_id]) if params[:test_id]  # If a specific test is selected
    @test ||= Test.new(assignment: @assignment)  # Default to a new test if no test is selected
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments or /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: "Assignment was successfully created." }
        format.json { render :show, status: :created, location: @assignment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1 or /assignments/1.json
  # PATCH/PUT /assignments/1 or /assignments/1.json
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment, notice: "Assignment was successfully updated." }
        format.json { render :show, status: :ok, location: @assignment }
        current_user = User.find(session[:user_id]) # Retrieve the current user
        auth_token = session[:github_token] # Get the GitHub auth token from the session
        update_remote(current_user, auth_token)
        redirect_to @assignment, notice: "Assignment was successfully updated."
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_remote(user, auth_token)
    # 1. Update code tests file
    # 2. Push changes to remote
    @assignment.push_changes_to_github(user, auth_token)
  end


  # DELETE /assignments/1 or /assignments/1.json
  def destroy
    @assignment.destroy!

    respond_to do |format|
      format.html { redirect_to assignments_path, status: :see_other, notice: "Assignment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Define the local repository path
  def local_repository_path
    "/Users/walkerjames/Autograded_frontend_new/test_app"
  end

  def create_and_download_zip
    # Find the assignment
    assignment = Assignment.find(params[:id])

    # Use self.local_repository_path instead of hardcoded path
    git_folder = self.local_repository_path

    # Use Dir.chdir to change directory and run make
    Dir.chdir(self.local_repository_path) do
      system("make")
    end

    # The original zip file created by the make command
    original_zip_file = File.join(self.local_repository_path, "autograder.zip")

    # The new zip file name based on the assignment name
    new_zip_filename = "#{assignment.assignment_name}.zip"

    flash[:notice] = "#{new_zip_filename} downloaded successfully"
    # Rename the autograder.zip to assignment_name.zip
    renamed_zip_path = File.join(self.local_repository_path, new_zip_filename)

    if File.exist?(original_zip_file)
      File.rename(original_zip_file, renamed_zip_path)
    end

    # Check if the renamed ZIP file exists and send it as a download
    if File.exist?(renamed_zip_path)
      send_file renamed_zip_path, type: "application/zip", disposition: "attachment", filename: new_zip_filename
    else
      flash[:alert] = "Could not export assignment"
      redirect_to assignment_path(params[:id])
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assignment_params
      params.require(:assignment).permit(:assignment_name, :repository_name, :repository_url)
    end
end
