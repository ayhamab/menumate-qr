class PromotionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :set_promotion, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner

  # GET /restaurants/:restaurant_id/promotions
  def index
    @promotions = @restaurant.promotions.order(start_date: :desc)
  end

  # GET /restaurants/:restaurant_id/promotions/:id
  def show
  end

  # GET /restaurants/:restaurant_id/promotions/new
  def new
    @promotion = @restaurant.promotions.build
    @promotion.start_date = Time.current.beginning_of_day
    @promotion.end_date = 7.days.from_now.end_of_day
    @promotion.active = true
  end

  # GET /restaurants/:restaurant_id/promotions/:id/edit
  def edit
  end

  # POST /restaurants/:restaurant_id/promotions
  def create
    # Check subscription limits
    unless @restaurant.within_limits?(:promotions, @restaurant.promotions.active.count)
      redirect_to restaurant_promotions_path(@restaurant), 
                  alert: "You've reached your plan's promotion limit. Please upgrade your subscription to create more promotions.",
                  status: :unprocessable_entity
      return
    end

    @promotion = @restaurant.promotions.build(promotion_params)

    if @promotion.save
      redirect_to restaurant_promotions_path(@restaurant), notice: "Promotion was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/promotions/:id
  def update
    if @promotion.update(promotion_params)
      redirect_to restaurant_promotions_path(@restaurant), notice: "Promotion was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/promotions/:id
  def destroy
    @promotion.destroy
    redirect_to restaurant_promotions_path(@restaurant), notice: "Promotion was successfully deleted."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_promotion
    @promotion = @restaurant.promotions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_promotions_path(@restaurant), alert: "Promotion not found."
  end

  def authorize_owner
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only manage promotions for your own restaurants."
      return
    end
  end

  def promotion_params
    params.require(:promotion).permit(:title, :description, :discount_type, :discount_value, :start_date, :end_date, :active, :badge_color, menu_item_ids: [])
  end
end
