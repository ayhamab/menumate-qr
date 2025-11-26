class MenuItemAssignmentsController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu_item
  before_action :require_team_access
  before_action :set_assignment, only: [:update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items/:menu_item_id/assignments
  def index
    @assignments = @menu_item.menu_item_assignments.includes(:assigned_to, :assigned_by).order(created_at: :desc)
    @team_members = @restaurant.restaurant_teams.active.includes(:user).where(role: ['chef', 'manager', 'staff'])
  end

  # POST /restaurants/:restaurant_id/menu_items/:menu_item_id/assignments
  def create
    @assignment = @menu_item.menu_item_assignments.build(assignment_params)
    @assignment.assigned_by = current_user if respond_to?(:current_user) && current_user

    if @assignment.save
      # Log activity
      log_activity('assignment_created', {
        assigned_to: @assignment.assigned_to.email,
        menu_item_name: @menu_item.name
      })

      redirect_to restaurant_menu_item_assignments_path(@restaurant, @menu_item), notice: "Menu item assigned successfully."
    else
      @assignments = @menu_item.menu_item_assignments.includes(:assigned_to, :assigned_by)
      @team_members = @restaurant.restaurant_teams.active.includes(:user).where(role: ['chef', 'manager', 'staff'])
      render :index, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/menu_items/:menu_item_id/assignments/:id
  def update
    if @assignment.update(assignment_params)
      # Log status changes
      if assignment_params[:status].present?
        log_activity('assignment_status_changed', {
          menu_item_name: @menu_item.name,
          assigned_to: @assignment.assigned_to.email,
          status: @assignment.status
        })
      end

      redirect_to restaurant_menu_item_assignments_path(@restaurant, @menu_item), notice: "Assignment updated successfully."
    else
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/menu_items/:menu_item_id/assignments/:id
  def destroy
    if @assignment.destroy
      log_activity('assignment_removed', {
        menu_item_name: @menu_item.name,
        assigned_to: @assignment.assigned_to.email
      })

      redirect_to restaurant_menu_item_assignments_path(@restaurant, @menu_item), notice: "Assignment removed."
    else
      redirect_to restaurant_menu_item_assignments_path(@restaurant, @menu_item), alert: "Could not remove assignment."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_path(@restaurant), alert: "Menu item not found."
  end

  def set_assignment
    @assignment = @menu_item.menu_item_assignments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_menu_item_assignments_path(@restaurant, @menu_item), alert: "Assignment not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def assignment_params
    params.require(:menu_item_assignment).permit(:assigned_to_id, :status, :priority, :notes, :due_date)
  end

  def log_activity(activity_type, metadata = {})
    return unless @restaurant.respond_to?(:activity_logs)
    
    @restaurant.activity_logs.create(
      user: respond_to?(:current_user) ? current_user : nil,
      trackable: @menu_item,
      activity_type: activity_type,
      metadata: metadata
    )
  rescue
    # Silently fail if activity logging isn't available
  end
end

