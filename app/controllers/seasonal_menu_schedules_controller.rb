class SeasonalMenuSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :set_seasonal_menu_schedule, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner

  # GET /restaurants/:restaurant_id/seasonal_menu_schedules
  def index
    @seasonal_menu_schedules = @restaurant.seasonal_menu_schedules
                                          .includes(:menu_item)
                                          .order(start_date: :desc, created_at: :desc)
    
    # Filter by status
    case params[:status]
    when 'active'
      @seasonal_menu_schedules = @seasonal_menu_schedules.current
    when 'upcoming'
      @seasonal_menu_schedules = @seasonal_menu_schedules.upcoming
    when 'past'
      @seasonal_menu_schedules = @seasonal_menu_schedules.past
    end
    
    @menu_items = @restaurant.menu_items.order(:name)
  end

  # GET /restaurants/:restaurant_id/seasonal_menu_schedules/:id
  def show
  end

  # GET /restaurants/:restaurant_id/seasonal_menu_schedules/new
  def new
    @seasonal_menu_schedule = @restaurant.seasonal_menu_schedules.build
    @menu_items = @restaurant.menu_items.order(:name)
  end

  # POST /restaurants/:restaurant_id/seasonal_menu_schedules
  def create
    @seasonal_menu_schedule = @restaurant.seasonal_menu_schedules.build(seasonal_menu_schedule_params)
    
    if @seasonal_menu_schedule.save
      redirect_to restaurant_seasonal_menu_schedules_path(@restaurant),
                  notice: "Seasonal menu schedule created successfully."
    else
      @menu_items = @restaurant.menu_items.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/seasonal_menu_schedules/:id/edit
  def edit
    @menu_items = @restaurant.menu_items.order(:name)
  end

  # PATCH/PUT /restaurants/:restaurant_id/seasonal_menu_schedules/:id
  def update
    if @seasonal_menu_schedule.update(seasonal_menu_schedule_params)
      redirect_to restaurant_seasonal_menu_schedules_path(@restaurant),
                  notice: "Seasonal menu schedule updated successfully."
    else
      @menu_items = @restaurant.menu_items.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/seasonal_menu_schedules/:id
  def destroy
    @seasonal_menu_schedule.destroy
    redirect_to restaurant_seasonal_menu_schedules_path(@restaurant),
                notice: "Seasonal menu schedule deleted successfully."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_seasonal_menu_schedule
    @seasonal_menu_schedule = @restaurant.seasonal_menu_schedules.find(params[:id])
  end

  def authorize_owner
    unless @restaurant.user == current_user || (@restaurant.corporate_account&.has_user?(current_user) && @restaurant.corporate_account.can_manage?(current_user))
      redirect_to restaurants_path, alert: "You don't have permission to manage this restaurant."
    end
  end

  def seasonal_menu_schedule_params
    params.require(:seasonal_menu_schedule).permit(
      :menu_item_id, :name, :start_date, :end_date, 
      :start_time, :end_time, :active, :recurring, :recurring_pattern
    )
  end
end
