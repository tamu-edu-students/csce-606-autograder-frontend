class TestsController < ApplicationController
  include TestsHelper
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
    @test = Test.new(test_params)

    respond_to do |format|
      if @test.save
        current_user, auth_token = current_user_and_token
        update_remote(current_user, auth_token)
        format.html { redirect_to @test, notice: "Test was successfully created." }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tests/1 or /tests/1.json
  def update
    respond_to do |format|
      if @test.update(test_params)
        current_user, auth_token = current_user_and_token
        update_remote(current_user, auth_token)
        format.html { redirect_to @test, notice: "Test was successfully updated." }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1 or /tests/1.json
  def destroy
    @test.destroy!

    respond_to do |format|
      current_user, auth_token = current_user_and_token
      update_remote(current_user, auth_token)
      format.html { redirect_to tests_path, status: :see_other, notice: "Test was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test
      @test = Test.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def test_params
      params.require(:test).permit(:name, :points, :type, :target, :include, :number, :show_output, :skip, :timeout, :visibility, :assignment_id)
    end
end
