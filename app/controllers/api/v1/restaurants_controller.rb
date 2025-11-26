class Api::V1::RestaurantsController < Api::V1::BaseController
  before_action :set_restaurant, only: [:show, :update, :destroy]

  # GET /api/v1/restaurants
  def index
    restaurants = current_user.restaurants
    restaurants = restaurants.where(cuisine: params[:cuisine]) if params[:cuisine].present?
    restaurants = restaurants.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?
    
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 20, 100].min # Max 100 per page
    
    # Simple pagination without gem
    offset = (page - 1) * per_page
    total = restaurants.count
    paginated_restaurants = restaurants.limit(per_page).offset(offset)
    total_pages = (total.to_f / per_page).ceil

    render json: {
      data: paginated_restaurants.map { |r| restaurant_to_json(r) },
      meta: {
        total: total,
        page: page,
        per_page: per_page,
        total_pages: total_pages
      }
    }
  end

  # GET /api/v1/restaurants/:id
  def show
    render json: {
      data: restaurant_to_json(@restaurant, include_menu_items: true)
    }
  end

  # POST /api/v1/restaurants
  def create
    restaurant = current_user.restaurants.build(restaurant_params)
    
    if restaurant.save
      render json: {
        data: restaurant_to_json(restaurant)
      }, status: :created
    else
      render json: {
        error: 'Validation failed',
        message: restaurant.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/restaurants/:id
  def update
    if @restaurant.update(restaurant_params)
      render json: {
        data: restaurant_to_json(@restaurant)
      }
    else
      render json: {
        error: 'Validation failed',
        message: @restaurant.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/restaurants/:id
  def destroy
    @restaurant.destroy
    render json: {
      message: 'Restaurant deleted successfully'
    }, status: :ok
  end

  private

  def set_restaurant
    @restaurant = current_user.restaurants.find(params[:id])
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :description, :address, :phone_number, :cuisine)
  end

  def restaurant_to_json(restaurant, include_menu_items: false)
    json = {
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      address: restaurant.address,
      phone_number: restaurant.phone_number,
      cuisine: restaurant.cuisine,
      menu_items_count: restaurant.menu_items.count,
      qr_scans_count: restaurant.qr_scans.count,
      created_at: restaurant.created_at.iso8601,
      updated_at: restaurant.updated_at.iso8601
    }

    if include_menu_items
      json[:menu_items] = restaurant.menu_items.ordered.map { |item| menu_item_to_json(item) }
    end

    json
  end

  def menu_item_to_json(item)
    {
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price.to_f,
      category: item.category,
      dietary_tags: item.dietary_tags || [],
      allergens: item.allergens || [],
      position: item.position,
      created_at: item.created_at.iso8601,
      updated_at: item.updated_at.iso8601
    }
  end
end
