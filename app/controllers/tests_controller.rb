class TestsController < ApplicationController
    before_action :set_assignment
    before_action :set_test, only: %i[edit update destroy]
  
    # GET /assignments/:assignment_id/tests
    def index
      @tests = @assignment.tests.sorted  # Retrieve all tests for the assignment, sorted by number
    end
  
    # GET /assignments/:assignment_id/tests/new
    # generate a form to create new test
    def new
      @test = @assignment.tests.new
    end
  
    # POST /assignments/:assignment_id/tests
    #create test using params(from the form)
    def create
      @test = @assignment.tests.new(test_params)
  
      respond_to do |format|
        if @test.save
          format.html { redirect_to assignment_tests_path(@assignment), notice: 'Test was successfully created.' }
          format.json { render :index, status: :created, location: assignment_tests_path(@assignment) }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @test.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # GET /assignments/:assignment_id/tests/:id/edit
    def edit
    end
  
    # PATCH/PUT /assignments/:assignment_id/tests/:id
    def update
      respond_to do |format|
        if @test.update(test_params)
          format.html { redirect_to assignment_tests_path(@assignment), notice: 'Test was successfully updated.' }
          format.json { render :index, status: :ok, location: assignment_tests_path(@assignment) }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @test.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /assignments/:assignment_id/tests/:id
    def destroy
      @test.destroy
  
      respond_to do |format|
        format.html { redirect_to assignment_tests_path(@assignment), status: :see_other, notice: 'Test was successfully deleted.' }
        format.json { head :no_content }
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:assignment_id])
    end
  
    def set_test
      @test = @assignment.tests.find(params[:id])
    end
  
    # Only allow a list of trusted parameters through.
    def test_params
      params.require(:test).permit(:name, :points, :type, :target, :include, :number, :show_output, :skip, :timeout, :visibility)
    end
  end
  
