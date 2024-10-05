class TestsController < ApplicationController
  before_action :set_assignment
  before_action :set_test, only: %i[ show edit update destroy ]

  def index
    @assignment = Assignment.find(params[:assignment_id])
    
    @tests = @assignment.tests
  end

  def new
    @test = @assignment.tests.build
  end

  def create
    @test = @assignment.tests.new(test_params)
    if @test.save
      @assignment.generate_tests_file  # Make sure this generates the .tests file
      redirect_to assignment_tests_path(@assignment), notice: 'Test was successfully created.'
    else
      render :new
    end
  end
  

  # GET /assignments/:assignment_id/tests/:id/edit
  def edit
  end

  # PATCH/PUT /assignments/:assignment_id/tests/:id
  def update
    if @test.update(test_params)
      redirect_to assignment_test_path(@assignment, @test), notice: "Test was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /assignments/:assignment_id/tests/:id
  def destroy
    @test.destroy
    redirect_to assignment_tests_path(@assignment, @test), notice: "Test was successfully deleted."
  end

  private
    def set_assignment
      @assignment = Assignment.find(params[:assignment_id])
    end

    def set_test
      @test = @assignment.tests.find(params[:id])
    end

    def test_params
      params.require(:test).permit(:name, :points, :target, :test_code, :test_type, :include_files)
    end    
end
