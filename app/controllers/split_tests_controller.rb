class SplitTestsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :require_edit_permission, except: [:index, :show]
  before_action :set_split_test, only: [:show, :edit, :update, :destroy, :start, :pause, :complete, :apply_winner]

  # GET /restaurants/:restaurant_id/split_tests
  def index
    @split_tests = @restaurant.split_tests.includes(:menu_item, :split_test_variants).order(created_at: :desc)
    @split_tests = @split_tests.where(status: params[:status]) if params[:status].present?
    @split_tests = @split_tests.by_type(params[:type]) if params[:type].present?
  end

  # GET /restaurants/:restaurant_id/split_tests/:id
  def show
    @variants = @split_test.split_test_variants.includes(:split_test_results).order(weight: :desc)
    @statistics = @split_test.statistics
  end

  # GET /restaurants/:restaurant_id/split_tests/new
  def new
    @split_test = @restaurant.split_tests.build
    @menu_items = @restaurant.menu_items.order(:name)
  end

  # POST /restaurants/:restaurant_id/split_tests
  def create
    @split_test = @restaurant.split_tests.build(split_test_params)
    @menu_items = @restaurant.menu_items.order(:name)

    if @split_test.save
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Split test created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/split_tests/:id/edit
  def edit
    @menu_items = @restaurant.menu_items.order(:name)
  end

  # PATCH/PUT /restaurants/:restaurant_id/split_tests/:id
  def update
    @menu_items = @restaurant.menu_items.order(:name)
    
    if @split_test.update(split_test_params)
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Split test updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/split_tests/:id
  def destroy
    if @split_test.destroy
      redirect_to restaurant_split_tests_path(@restaurant), notice: "Split test deleted."
    else
      redirect_to restaurant_split_test_path(@restaurant, @split_test), alert: "Could not delete split test."
    end
  end

  # POST /restaurants/:restaurant_id/split_tests/:id/start
  def start
    if @split_test.split_test_variants.count < 2
      redirect_to restaurant_split_test_path(@restaurant, @split_test), alert: "You need at least 2 variants to start a test."
      return
    end

    @split_test.update(status: 'active', started_at: Time.current)
    redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Split test started."
  end

  # POST /restaurants/:restaurant_id/split_tests/:id/pause
  def pause
    @split_test.update(status: 'paused')
    redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Split test paused."
  end

  # POST /restaurants/:restaurant_id/split_tests/:id/complete
  def complete
    winner = @split_test.split_test_variants.find_by(id: params[:winner_variant_id])
    
    if winner
      @split_test.update(
        status: 'completed',
        completed_at: Time.current,
        winner_variant_id: winner.id
      )
      
      if params[:apply_winner] == 'true'
        @split_test.apply_winner
      end
      
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Split test completed. Winner: #{winner.name}"
    else
      redirect_to restaurant_split_test_path(@restaurant, @split_test), alert: "Please select a winning variant."
    end
  end

  # POST /restaurants/:restaurant_id/split_tests/:id/apply_winner
  def apply_winner
    if @split_test.completed? && @split_test.winner_variant_id.present?
      @split_test.apply_winner
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Winner applied to menu item."
    else
      redirect_to restaurant_split_test_path(@restaurant, @split_test), alert: "Test must be completed with a winner selected."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_split_test
    @split_test = @restaurant.split_tests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_split_tests_path(@restaurant), alert: "Split test not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_split_tests_path(@restaurant), alert: "You don't have permission to manage split tests."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def split_test_params
    params.require(:split_test).permit(:name, :test_type, :menu_item_id, :status, :auto_apply_winner, :notes)
  end
end

