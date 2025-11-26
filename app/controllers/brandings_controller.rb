class BrandingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :authorize_owner
  before_action :check_white_label_access
  before_action :set_branding

  # GET /restaurants/:restaurant_id/branding
  def show
    redirect_to edit_restaurant_branding_path(@restaurant)
  end

  # GET /restaurants/:restaurant_id/branding/edit
  def edit
  end

  # PATCH/PUT /restaurants/:restaurant_id/branding
  def update
    # Handle logo removal
    if params[:branding][:remove_logo] == '1'
      @branding.logo.purge if @branding.logo.attached?
    end
    
    # Handle favicon removal
    if params[:branding][:remove_favicon] == '1'
      @branding.favicon.purge if @branding.favicon.attached?
    end

    if @branding.update(branding_params.except(:remove_logo, :remove_favicon))
      redirect_to edit_restaurant_branding_path(@restaurant), notice: "Branding updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_branding
    @branding = @restaurant.branding || @restaurant.build_branding
  end

  def authorize_owner
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only manage branding for your own restaurants."
      return
    end
  end

  def check_white_label_access
    unless @restaurant.can_use_white_label?
      redirect_to restaurant_subscription_path(@restaurant), 
                  alert: "White-label branding is only available for Enterprise plan subscribers. Please upgrade to access this feature."
      return
    end
  end

  def branding_params
    params.require(:branding).permit(:primary_color, :secondary_color, :accent_color, :font_family, 
                                     :logo, :favicon, :custom_css, :company_name, :tagline, 
                                     :hide_menumate_branding, :custom_domain, :remove_logo, :remove_favicon)
  end
end
