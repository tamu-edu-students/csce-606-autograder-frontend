
class TestsController < ApplicationController
  include TestsHelper

  before_action :set_assignment
  before_action :set_test, only: [ :show, :edit, :update, :destroy ]


  # GET /tests or /tests.json
  def index
    @tests = Test.all
  end

  # GET /tests/1 or /tests/1.json
  def show
  end

  # GET /tests/new
  def new
    @test = Test.new
  end

  # GET /tests/1/edit
  def edit
  end

  # POST /tests or /tests.json
  def create
    @test = Test.new(test_params)
    @assignment = Assignment.find(params[:assignment_id])
    @test.assignment = @assignment

    respond_to do |format|
      if @test.save
        current_user, auth_token = current_user_and_token
        update_remote(current_user, auth_token)
        format.html { redirect_to assignment_path(@assignment), notice: "Test was successfully created." }
        format.json { render :show, status: :created, location: @test }
      else
        # Collect error messages and merge them
        error_messages = @test.errors.full_messages
        combined_errors = merge_error_messages(error_messages)
        flash[:alert] = combined_errors
        format.html { redirect_to assignment_path(@assignment), notice: "#{flash[:alert]}" }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /tests/1 or /tests/1.json
  def update
    @assignment = Assignment.find(params[:assignment_id])  # Ensure @assignment is set
    @test = @assignment.tests.find(params[:id])            # Find the test within the assignment

    respond_to do |format|
      if @test.update(test_params)
        current_user, auth_token = current_user_and_token
        update_remote(current_user, auth_token)
        format.html { redirect_to assignment_path(@assignment), notice: "Test was successfully updated." }
        format.json { render :show, status: :ok, location: @test }
      else
         # Collect error messages and merge them
         error_messages = @test.errors.full_messages
         combined_errors = merge_error_messages(error_messages)
         flash[:alert] = combined_errors
         format.html { redirect_to assignment_path(@assignment), notice: "#{flash[:alert]}" }
         format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /assignments/:assignment_id/tests/:id
  def destroy
    @assignment = Assignment.find(params[:assignment_id])
    @test = @assignment.tests.find(params[:id])
    @test.destroy

    respond_to do |format|
      current_user, auth_token = current_user_and_token
      update_remote(current_user, auth_token)
      format.html { redirect_to assignment_path(@assignment), status: :see_other, notice: "Test was successfully destroyed." }
      format.json { head :no_content }
    end
  end



  private

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id])
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_test
    @assignment = Assignment.find(params[:assignment_id])  # Find the assignment first
    @test = @assignment.tests.find(params[:id])  # Find the test within the context of the assignment
  end

  def merge_error_messages(errors)
    # Separate "Missing attribute" errors and other errors
    missing_attributes = []
    other_errors = []

    errors.each do |message|
      # Extract the attribute name from the error message if it matches "Missing attribute: <attribute>"
      if (match = message.match(/Missing attribute: (\w+)/))
        missing_attributes << match[1]
      else
        other_errors << message
      end
    end

  # Build the final error message
  final_error_message = []

  # If there are any missing attributes, add them to the final message
  if missing_attributes.any?
    final_error_message << "Missing attributes: #{missing_attributes.join(', ')}"
  end

  # Add any other errors to the final message
  final_error_message.concat(other_errors)

  # Return the joined error messages
  final_error_message.join(", ")
end

private

  # Only allow a list of trusted parameters through.
  def test_params
    params.require(:test).permit(:name, :points, :test_type, :target, :include, :number, :show_output, :skip, :timeout, :visibility, :assignment_id, :actual_test, :test_grouping_id)
  end
end
