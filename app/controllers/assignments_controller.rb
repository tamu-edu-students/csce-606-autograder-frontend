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
    assignment_params[:repository_name].downcase!
    @assignment = Assignment.new(assignment_params)

    github_token = session[:github_token]
    @assignment.assignment_repo_init(github_token)

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
    assignment_params[:repository_name].downcase!

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

    # Use Dir.chdir to change directory and run make
    Dir.chdir(assignment.local_repository_path) do
      system("make")
    end

    # The original zip file created by the make command
    original_zip_file = File.join(assignment.local_repository_path, "autograder.zip")

    # The new zip file name based on the assignment name
    new_zip_filename = "#{assignment.assignment_name}.zip"

    # Rename the autograder.zip to assignment_name.zip
    renamed_zip_path = File.join(assignment.local_repository_path, new_zip_filename)

    if File.exist?(original_zip_file)
      File.rename(original_zip_file, renamed_zip_path)
    end

    # Check if the renamed ZIP file exists and send it as a download
    if File.exist?(renamed_zip_path)
      send_file renamed_zip_path, type: "application/zip", disposition: "attachment", filename: new_zip_filename
      flash[:notice] = "#{new_zip_filename} downloaded successfully"
    else
      flash[:alert] = "Could not export assignment"
      redirect_to assignment_path(params[:id])
    end
  end

  def search
    if params[:query].present?
      @assignments = Assignment.where("repository_name LIKE ?", "%#{params[:query]}%")
    else
      @assignments = Assignment.all
      redirect_to assignments_path
      return
    end

    if @assignments.empty?
      flash[:alert] = "No matching assignments found"
      @assignments = Assignment.all
      redirect_to assignments_path
      return
    end

    render :index
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
