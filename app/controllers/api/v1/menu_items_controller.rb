class Api::V1::MenuItemsController < Api::V1::BaseController
  before_action :set_restaurant
  before_action :set_menu_item, only: [:show, :update, :destroy]

  # GET /api/v1/restaurants/:restaurant_id/menu_items
  def index
    menu_items = @restaurant.menu_items
    menu_items = menu_items.where(category: params[:category]) if params[:category].present?
    menu_items = menu_items.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?
    
    # Filter by dietary tags
    if params[:dietary_tag].present?
      menu_items = menu_items.where("dietary_tags LIKE ?", "%\"#{params[:dietary_tag]}\"%")
    end
    
    menu_items = menu_items.ordered
    
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 20, 100].min
    
    # Simple pagination without gem
    offset = (page - 1) * per_page
    total = menu_items.count
    paginated_menu_items = menu_items.limit(per_page).offset(offset)
    total_pages = (total.to_f / per_page).ceil

    render json: {
      data: paginated_menu_items.map { |item| menu_item_to_json(item) },
      meta: {
        total: total,
        page: page,
        per_page: per_page,
        total_pages: total_pages,
        restaurant_id: @restaurant.id
      }
    }
  end

  # GET /api/v1/restaurants/:restaurant_id/menu_items/:id
  def show
    render json: {
      data: menu_item_to_json(@menu_item, include_image_url: true)
    }
  end

  # POST /api/v1/restaurants/:restaurant_id/menu_items
  def create
    menu_item = @restaurant.menu_items.build(menu_item_params)
    
    if menu_item.save
      render json: {
        data: menu_item_to_json(menu_item)
      }, status: :created
    else
      render json: {
        error: 'Validation failed',
        message: menu_item.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/restaurants/:restaurant_id/menu_items/:id
  def update
    if @menu_item.update(menu_item_params)
      render json: {
        data: menu_item_to_json(@menu_item)
      }
    else
      render json: {
        error: 'Validation failed',
        message: @menu_item.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/restaurants/:restaurant_id/menu_items/:id
  def destroy
    @menu_item.destroy
    render json: {
      message: 'Menu item deleted successfully'
    }, status: :ok
  end

  private

  def set_restaurant
    @restaurant = current_user.restaurants.find(params[:restaurant_id])
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :category, :position, dietary_tags: [], allergens: [])
  end

  def menu_item_to_json(item, include_image_url: false)
    json = {
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price.to_f,
      category: item.category,
      dietary_tags: item.dietary_tags || [],
      allergens: item.allergens || [],
      position: item.position,
      average_rating: item.average_rating&.to_f,
      rating_count: item.rating_count,
      created_at: item.created_at.iso8601,
      updated_at: item.updated_at.iso8601
    }

    if include_image_url && item.image.attached?
      json[:image_url] = rails_blob_url(item.image, only_path: false)
    end

    json
  end
end
