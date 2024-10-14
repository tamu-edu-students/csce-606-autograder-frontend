class TestGroupingsController < ApplicationController
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

  # GET /test_groupings/1/edit
  def edit
  end

  # POST /test_groupings or /test_groupings.json
  def create
    @test_grouping = TestGrouping.new(test_grouping_params)

    respond_to do |format|
      if @test_grouping.save
        format.html { redirect_to @test_grouping, notice: "Test grouping was successfully created." }
        format.json { render :show, status: :created, location: @test_grouping }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @test_grouping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /test_groupings/1 or /test_groupings/1.json
  def update
    respond_to do |format|
      if @test_grouping.update(test_grouping_params)
        format.html { redirect_to @test_grouping, notice: "Test grouping was successfully updated." }
        format.json { render :show, status: :ok, location: @test_grouping }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @test_grouping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_groupings/1 or /test_groupings/1.json
  def destroy
    @test_grouping.destroy!

    respond_to do |format|
      format.html { redirect_to test_groupings_path, status: :see_other, notice: "Test grouping was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_grouping
      @test_grouping = TestGrouping.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def test_grouping_params
      params.fetch(:test_grouping, {})
    end
end
