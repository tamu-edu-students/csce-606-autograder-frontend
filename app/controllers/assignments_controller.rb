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
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to @assignment, notice: "Assignment was successfully updated." }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1 or /assignments/1.json
  def destroy
    @assignment.destroy!

    respond_to do |format|
      format.html { redirect_to assignments_path, status: :see_other, notice: "Assignment was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def create_and_download_zip
    # Find the assignment
    assignment = Assignment.find(params[:id])

    # The WSL path where the make command should be executed
    git_folder = '/home/banna/CoreGrader/testRepository'

    # Run the make command in the specified WSL directory
    system("cd #{git_folder} && make")

    # The original zip file created by the make command
    original_zip_file = File.join(git_folder, 'autograder.zip')

    # The new zip file name based on the assignment name
    zip_filename = "#{assignment.assignment_name}.zip"
    zip_file_path = File.join(git_folder, zip_filename)

    # Rename the autograder.zip to assignment_name.zip
    if File.exist?(original_zip_file)
      File.rename(original_zip_file, zip_file_path)
    end

    # Check if the renamed ZIP file exists and send it as a download
    if File.exist?(zip_file_path)
      send_file zip_file_path, type: 'application/zip', disposition: 'attachment', filename: zip_filename
      flash[:notice] = "#{zip_filename} downloaded successfully"
    else
      flash[:alert] = "ZIP file not found. Please ensure the make command works correctly."
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
