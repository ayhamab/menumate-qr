class MenuItemCommentsController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu_item
  before_action :require_team_access
  before_action :set_comment, only: [:update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items/:menu_item_id/comments
  def index
    @comments = @menu_item.menu_item_comments.top_level.includes(:user, :replies).order(created_at: :desc)
    @comment = @menu_item.menu_item_comments.build
  end

  # POST /restaurants/:restaurant_id/menu_items/:menu_item_id/comments
  def create
    @comment = @menu_item.menu_item_comments.build(comment_params)
    @comment.user = current_user if respond_to?(:current_user) && current_user

    if @comment.save
      # Log activity
      log_activity('comment_added', {
        comment_id: @comment.id
      })

      redirect_to restaurant_menu_item_comments_path(@restaurant, @menu_item), notice: "Comment added successfully."
    else
      @comments = @menu_item.menu_item_comments.top_level.includes(:user, :replies)
      render :index, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/menu_items/:menu_item_id/comments/:id
  def update
    if @comment.update(comment_params)
      redirect_to restaurant_menu_item_comments_path(@restaurant, @menu_item), notice: "Comment updated successfully."
    else
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/menu_items/:menu_item_id/comments/:id
  def destroy
    if @comment.destroy
      redirect_to restaurant_menu_item_comments_path(@restaurant, @menu_item), notice: "Comment deleted."
    else
      redirect_to restaurant_menu_item_comments_path(@restaurant, @menu_item), alert: "Could not delete comment."
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

  def set_comment
    @comment = @menu_item.menu_item_comments.find(params[:id])
    
    # Only allow user to edit/delete their own comments (or managers)
    unless can_edit_comment?(@comment)
      redirect_to restaurant_menu_item_comments_path(@restaurant, @menu_item), alert: "You don't have permission to edit this comment."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_menu_item_comments_path(@restaurant, @menu_item), alert: "Comment not found."
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

  def can_edit_comment?(comment)
    return false unless respond_to?(:current_user) && current_user
    return true if comment.user == current_user
    
    # Managers can edit any comment
    team_member = @restaurant.restaurant_teams.active.find_by(user: current_user)
    team_member&.can_manage_team? || false
  end

  def comment_params
    params.require(:menu_item_comment).permit(:content, :parent_id)
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

