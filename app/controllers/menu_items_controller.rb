class MenuItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :reorder]
  before_action :set_restaurant
  before_action :set_menu_item, only: [:show, :edit, :update, :destroy, :track_click, :track_order]
  before_action :authorize_owner, only: [:new, :create, :edit, :update, :destroy, :reorder]

  # GET /restaurants/:restaurant_id/menu_items
  def index
    @menu_items = @restaurant.menu_items.ordered
    @menu_items_by_category = @menu_items.group_by(&:category)
    @categories = MenuItem.default_categories + @restaurant.menu_items.categories
    @categories = @categories.uniq.compact.sort
  end

  # PATCH /restaurants/:restaurant_id/menu_items/reorder
  def reorder
    positions = params[:positions] || []
    
    if positions.empty?
      render json: { status: 'error', message: 'No positions provided' }, status: :unprocessable_entity
      return
    end
    
    ActiveRecord::Base.transaction do
      positions.each_with_index do |item_id, index|
        menu_item = @restaurant.menu_items.find_by(id: item_id)
        next unless menu_item
        menu_item.update_column(:position, index + 1)
      end
    end
    
    render json: { status: 'success' }
  rescue => e
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end

  # GET /restaurants/:restaurant_id/menu_items/:id
  def show
  end

  # GET /restaurants/:restaurant_id/menu_items/new
  def new
    @menu_item = @restaurant.menu_items.build
    @brands = @restaurant.brands.active.ordered
  end

  # GET /restaurants/:restaurant_id/menu_items/:id/edit
  def edit
    @brands = @restaurant.brands.active.ordered
  end

  # POST /restaurants/:restaurant_id/menu_items
  def create
    # Check subscription limits
    unless @restaurant.within_limits?(:menu_items, @restaurant.menu_items.count)
      redirect_to restaurant_menu_items_path(@restaurant), 
                  alert: "You've reached your plan's menu item limit. Please upgrade your subscription to add more items.",
                  status: :unprocessable_entity
      return
    end

    @menu_item = @restaurant.menu_items.build(menu_item_params)

    respond_to do |format|
      if @menu_item.save
        format.html { redirect_to restaurant_menu_items_path(@restaurant), notice: "Menu item was successfully created." }
        format.turbo_stream { redirect_to restaurant_menu_items_path(@restaurant), notice: "Menu item was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/menu_items/:id
  def update
    # Handle image removal
    if params[:menu_item][:remove_image] == "1"
      @menu_item.image.purge
    end
    
    respond_to do |format|
      if @menu_item.update(menu_item_params.except(:remove_image))
        format.html { redirect_to restaurant_menu_items_path(@restaurant), notice: "Menu item was successfully updated." }
        format.turbo_stream { redirect_to restaurant_menu_items_path(@restaurant), notice: "Menu item was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /restaurants/:restaurant_id/menu_items/:id
  def destroy
    @menu_item.destroy
    
    respond_to do |format|
      format.html { redirect_to restaurant_menu_items_url(@restaurant), notice: "Menu item was successfully destroyed." }
      format.turbo_stream
    end
  end

  # POST /restaurants/:restaurant_id/menu_items/:id/track_click
  def track_click
    MenuItemAnalytics.track_click(@menu_item, request)
    head :ok
  rescue
    head :ok # Silently fail if analytics not available
  end

  # POST /restaurants/:restaurant_id/menu_items/:id/track_order
  def track_order
    revenue = params[:revenue]&.to_f || @menu_item.price || 0
    MenuItemAnalytics.track_order(@menu_item, revenue: revenue, request: request)
    head :ok
  rescue
    head :ok # Silently fail if analytics not available
  end

  private

  # Set the restaurant from the nested route
  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  # Set the menu item from the nested route
  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_menu_items_path(@restaurant), alert: "Menu item not found."
  end

  # Authorize that the current user owns the restaurant
  def authorize_owner
    # Since authenticate_user! is called first, we know user is signed in
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only manage menu items for your own restaurants."
      return
    end
  end

  # Only allow a list of trusted parameters through
  def menu_item_params
    permitted = params.require(:menu_item).permit(:name, :description, :price, :image, :remove_image, :category, :position, :brand_id, dietary_tags: [], allergens: [], name_translations: {}, description_translations: {})
    # Filter out empty strings from dietary_tags array
    permitted[:dietary_tags] = permitted[:dietary_tags].reject(&:blank?) if permitted[:dietary_tags]
    # Filter out empty strings from allergens array
    permitted[:allergens] = permitted[:allergens].reject(&:blank?) if permitted[:allergens]
    # Filter out empty translation values
    permitted[:name_translations] = permitted[:name_translations]&.reject { |k, v| v.blank? } if permitted[:name_translations]
    permitted[:description_translations] = permitted[:description_translations]&.reject { |k, v| v.blank? } if permitted[:description_translations]
    permitted
  end
end

