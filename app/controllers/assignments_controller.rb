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

  def users
    @users = User.all
    @assignment = Assignment.find(params[:id])
  end

  def update_users
    @assignment = Assignment.find(params[:id])
    @users = User.all

    all_user_ids = User.pluck(:id)

    read_user_ids = (params[:read_user_ids] || []).map(&:to_i)
    write_user_ids = (params[:write_user_ids] || []).map(&:to_i)

    # Get assignment ids not in read or write
    none_user_ids = all_user_ids - (read_user_ids + write_user_ids)

    # Update or create permissions for read access
    read_user_ids.each do |user_id|
      permission = Permission.find_or_initialize_by(user_id: user_id, assignment: @assignment)
      permission.update(role: "read")
    end

    # Update or create permissions for write access
    write_user_ids.each do |user_id|
      permission = Permission.find_or_initialize_by(user_id: user_id, assignment: @assignment)
      permission.update(role: "read_write")
    end

    none_user_ids.each do |user_id|
      permission = Permission.find_or_initialize_by(user_id: user_id, assignment: @assignment)
      permission.update(role: "no_permission")
    end

    if @assignment.save
        # Update GitHub permissions
        begin
            update_github_permissions(@assignment)
            flash[:notice] = "Assignment #{@assignment.repository_name} permission updated successfully."
            redirect_to assignments_path
        rescue Octokit::Error => e
            Rails.logger.error "Failed to update GitHub permissions: #{e.message}"
            flash[:alert] = "Failed to update assignments. Please try again."
            @users = User.all
            render :show
        end
    else
        @assignments ||= []
        flash.now[:alert] = "Failed to update assignments. Please try again."
        render :show
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

    def update_github_permissions(assignment)
      access_token = session[:github_token]
      client = Octokit::Client.new(access_token: access_token)
      org_name = "AutograderFrontend"

      # All assignments that need to be updated
      @users = User.all


      @users.each do |user|
        repo_identifier = "#{org_name}/#{assignment.repository_name}"

        # Fetch the user's permission for the current assignment
        permission = Permission.find_by(user: user, assignment: assignment)


        if permission.role == "no_permission" || permission.role.nil?
          begin
            client.remove_collaborator(repo_identifier, user.name)
            Rails.logger.info "Removed collaborator #{user.name} from #{repo_identifier} due to 'none' permission"
          rescue Octokit::Error => e
            Rails.logger.error "Failed to remove collaborator #{user.name} from #{repo_identifier}: #{e.message}"
            raise
          end
        elsif permission.role == "read_write" || permission.role == "read"
          # Use ternary operator for selecting permission
          github_permission = (permission.role == "read_write") ? "push" : "pull"
          begin
            client.add_collaborator(repo_identifier, user.name, permission: github_permission)
            Rails.logger.info "Updated collaborator #{user.name} on #{repo_identifier} with #{github_permission} access"
          rescue Octokit::Error => e
            Rails.logger.error "Failed to update collaborator #{user.name} on #{repo_identifier}: #{e.message}"
            raise
          end
        else
          Rails.logger.error "Unknown permission role: #{permission.role} for user #{user.name} on assignment #{assignment.id}"
        end
      end
    end
end
