class TestsController < ApplicationController
  before_action :set_assignment
  before_action :set_test, only: %i[ show edit update destroy ]
  

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
    @assignment = Assignment.find(params[:assignment_id])  # Find the relevant assignment
    @test = @assignment.tests.new(test_params)  # Associate test with the assignment
  
    respond_to do |format|
      if @test.save
        format.html { redirect_to assignment_tests_path(@assignment), notice: "Test was successfully created." }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new, status: :unprocessable_entity }
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
        format.html { redirect_to assignment_test_path(@assignment, @test), notice: "Test was successfully updated." }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # DELETE /tests/1 or /tests/1.json
  def destroy
    @assignment = Assignment.find(params[:assignment_id])
    @test = @assignment.tests.find(params[:id])
    @test.destroy
  
    respond_to do |format|
      format.html { redirect_to assignment_tests_path(@assignment), status: :see_other, notice: "Test was successfully destroyed." }
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
    

    # Only allow a list of trusted parameters through.
    def test_params
      params.require(:test).permit(:name, :points, :test_type, :target, :include, :number, :show_output, :skip, :timeout, :visibility, :assignment_id, :actual_test)
    end
end
