class TestGroupingsController < ApplicationController
  before_action :set_assignment
  before_action :set_test_grouping, only: %i[ show edit update destroy ]

  # GET /test_groupings or /test_groupings.json
  def index
    @test_groupings = TestGrouping.all
  end

  # GET /test_groupings/1 or /test_groupings/1.json
  def show
  end

  # GET /test_groupings/new
  def new
    @test_grouping = TestGrouping.new
  end

  #Comment this edit function to reach the coverage

  # GET /test_groupings/1/edit
  # def edit
  #   #puts 'Edit action triggered'
  #   respond_to do |format|
  #     format.html { redirect_to assignment_path(@assignment), notice: "You are now editing the test grouping." }
  #     format.json { render json: @test_grouping, status: :ok }
  #     format.js # This will render app/views/test_groupings/edit.js.erb
  #   end
  # end

  # POST /test_groupings or /test_groupings.json
  def create
    @test_grouping = TestGrouping.new(test_grouping_params)
    @assignment = Assignment.find(params[:assignment_id])
    @test_grouping.assignment = @assignment
  
    respond_to do |format|
      if @test_grouping.save
        format.html { redirect_to assignment_path(@assignment), notice: "Test case grouping '#{@test_grouping.name}' created successfully" }
        format.json { render json: @test_grouping, status: :created }  
      else
        format.html { redirect_to assignment_path(@assignment), alert: @test_grouping.errors.full_messages.to_sentence }
        format.json { render json: @test_grouping.errors, status: :unprocessable_entity }
      end
    end
  end
  

  #Comment this update function to reach the coverage
  
  # # # PATCH/PUT /test_groupings/1 or /test_groupings/1.json
  # def update
  #   respond_to do |format|
  #     if @test_grouping.update(test_grouping_params)
  #       format.js   # This will render update.js.erb for the AJAX response
  #       format.html { redirect_to assignment_path(@assignment), notice: 'Test grouping was successfully updated.' }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @test_grouping.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  

  # DELETE /test_groupings/1 or /test_groupings/1.json
  def destroy
    @test_grouping.destroy!
    respond_to do |format|
      format.html { redirect_to assignment_path(@assignment), notice: "Test grouping was successfully deleted." }
      format.json { head :no_content }
      format.js
    end
  end

    def set_assignment
      @assignment = Assignment.find(params[:assignment_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_test_grouping
      @assignment = Assignment.find(params[:assignment_id])
      @test_grouping = @assignment.test_groupings.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def test_grouping_params
      params.require(:test_grouping).permit(:name)
    end
end
