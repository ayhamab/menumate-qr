class OnboardingController < ApplicationController
  before_action :require_authentication, except: [:welcome]
  before_action :set_restaurant, only: [:step2, :step3, :step4, :complete]

  def welcome
    # Welcome page - no authentication required
  end

  def step1
    # Step 1: Basic restaurant info
    @restaurant = current_user.restaurants.build if respond_to?(:current_user) && current_user
    @restaurant ||= Restaurant.new
  end

  def create_step1
    @restaurant = current_user.restaurants.build(restaurant_params) if respond_to?(:current_user) && current_user
    @restaurant ||= Restaurant.new(restaurant_params)
    
    if @restaurant.save
      redirect_to onboarding_step2_path(@restaurant), notice: "Great! Let's add your first menu items."
    else
      render :step1, status: :unprocessable_entity
    end
  end

  def step2
    # Step 2: Quick menu items setup
    @menu_items = @restaurant.menu_items.order(:created_at)
    @sample_categories = ['Appetizers', 'Main Courses', 'Desserts', 'Beverages', 'Specials']
  end

  def create_step2
    # Create multiple menu items at once
    items_created = 0
    errors = []
    
    if params[:menu_items].present?
      params[:menu_items].each do |item_params|
        next if item_params[:name].blank?
        
        menu_item = @restaurant.menu_items.build(
          name: item_params[:name],
          description: item_params[:description],
          price: item_params[:price] || 0,
          category: item_params[:category] || 'Main Courses',
          dietary_tags: item_params[:dietary_tags] || []
        )
        
        if menu_item.save
          items_created += 1
        else
          errors << "#{item_params[:name]}: #{menu_item.errors.full_messages.join(', ')}"
        end
      end
    end
    
    if items_created > 0
      redirect_to onboarding_step3_path(@restaurant), 
                  notice: "Added #{items_created} menu item#{items_created > 1 ? 's' : ''}!"
    else
      redirect_to onboarding_step2_path(@restaurant), 
                  alert: "Please add at least one menu item. #{errors.join('; ')}"
    end
  end

  def step3
    # Step 3: Customize and preview
    @menu_items = @restaurant.menu_items.order(:category, :name)
  end

  def step4
    # Step 4: Generate QR code and complete
    @qr_code_url = @restaurant.qr_codes.first&.qr_code_url || 
                   @restaurant.generate_qr_code.qr_code_url rescue nil
  end

  def complete
    # Mark onboarding as complete
    session[:onboarding_complete] = true
    redirect_to restaurant_path(@restaurant), 
                notice: "🎉 Your restaurant is ready! Share your QR code with customers."
  end

  def skip_onboarding
    session[:onboarding_complete] = true
    redirect_to restaurants_path
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id] || params[:id])
    unless can_access_restaurant?(@restaurant)
      redirect_to restaurants_path, alert: "Restaurant not found."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def require_authentication
    unless respond_to?(:current_user) && current_user
      redirect_to new_user_session_path, alert: "Please sign in to continue."
    end
  rescue
    redirect_to root_path, alert: "Please sign in to continue."
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :description, :address, :phone_number, :cuisine)
  end
end
