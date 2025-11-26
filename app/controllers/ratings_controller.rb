class RatingsController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu_item

  # POST /restaurants/:restaurant_id/menu_items/:menu_item_id/ratings
  def create
    @rating = @menu_item.ratings.build(rating_params)
    @rating.ip_address = request.remote_ip
    @rating.user_agent = request.user_agent

    respond_to do |format|
      if @rating.save
        format.html { redirect_to menu_restaurant_path(@restaurant), notice: "Thank you for your rating!" }
        format.turbo_stream { render :create }
        format.json { render json: { status: 'success', average_rating: @menu_item.average_rating, rating_count: @menu_item.rating_count } }
      else
        format.html { redirect_to menu_restaurant_path(@restaurant), alert: "Unable to submit rating. #{@rating.errors.full_messages.join(', ')}" }
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.json { render json: { status: 'error', errors: @rating.errors.full_messages }, status: :unprocessable_entity }
      end
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
    redirect_to menu_restaurant_path(@restaurant), alert: "Menu item not found."
  end

  def rating_params
    params.require(:rating).permit(:rating, :comment)
  end
end
