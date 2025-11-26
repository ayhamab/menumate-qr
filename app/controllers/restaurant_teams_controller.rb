class RestaurantTeamsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :require_team_management, only: [:create, :update, :destroy]
  before_action :set_restaurant_team, only: [:show, :edit, :update, :destroy]

  # GET /restaurants/:restaurant_id/team
  def index
    @restaurant_teams = @restaurant.restaurant_teams.active.includes(:user).order(role: :asc, created_at: :desc)
    @pending_invitations = @restaurant.restaurant_team_invitations.pending if @restaurant.respond_to?(:restaurant_team_invitations)
  end

  # GET /restaurants/:restaurant_id/team/new
  def new
    @restaurant_team = @restaurant.restaurant_teams.build
    @available_users = User.where.not(id: @restaurant.team_members.pluck(:id))
  end

  # POST /restaurants/:restaurant_id/team
  def create
    @restaurant_team = @restaurant.restaurant_teams.build(restaurant_team_params)
    @restaurant_team.assigned_by = current_user if respond_to?(:current_user) && current_user

    if @restaurant_team.save
      # Log activity
      log_activity('team_member_added', {
        member_name: @restaurant_team.user.email,
        role: @restaurant_team.role
      })

      redirect_to restaurant_team_index_path(@restaurant), notice: "#{@restaurant_team.user.email} has been added to the team as #{@restaurant_team.role}."
    else
      @available_users = User.where.not(id: @restaurant.team_members.pluck(:id))
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/team/:id/edit
  def edit
  end

  # PATCH/PUT /restaurants/:restaurant_id/team/:id
  def update
    old_role = @restaurant_team.role
    
    if @restaurant_team.update(restaurant_team_params)
      # Log activity if role changed
      if old_role != @restaurant_team.role
        log_activity('team_member_role_changed', {
          member_name: @restaurant_team.user.email,
          old_role: old_role,
          new_role: @restaurant_team.role
        })
      end

      redirect_to restaurant_team_index_path(@restaurant), notice: "Team member updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/team/:id
  def destroy
    member_email = @restaurant_team.user.email
    
    if @restaurant_team.destroy
      # Log activity
      log_activity('team_member_removed', {
        member_name: member_email
      })

      redirect_to restaurant_team_index_path(@restaurant), notice: "#{member_email} has been removed from the team."
    else
      redirect_to restaurant_team_index_path(@restaurant), alert: "Could not remove team member."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_restaurant_team
    @restaurant_team = @restaurant.restaurant_teams.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_team_index_path(@restaurant), alert: "Team member not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant's team."
    end
  end

  def require_team_management
    unless can_manage_team?(@restaurant)
      redirect_to restaurant_team_index_path(@restaurant), alert: "You don't have permission to manage the team."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    
    # Owner can always access
    return true if restaurant.user == current_user
    
    # Check if user is a team member
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def can_manage_team?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    
    # Owner can always manage
    return true if restaurant.user == current_user
    
    # Check if user is manager or owner
    team_member = restaurant.restaurant_teams.active.find_by(user: current_user)
    team_member&.can_manage_team? || false
  end

  def restaurant_team_params
    params.require(:restaurant_team).permit(:user_id, :role, :active)
  end

  def log_activity(activity_type, metadata = {})
    return unless @restaurant.respond_to?(:activity_logs)
    
    @restaurant.activity_logs.create(
      user: respond_to?(:current_user) ? current_user : nil,
      activity_type: activity_type,
      metadata: metadata
    )
  rescue
    # Silently fail if activity logging isn't available
  end
end

