class RestaurantsController < ApplicationController
  before_action :require_authentication, only: [:new, :create, :edit, :update, :destroy, :qr_code_png, :qr_code_svg]
  before_action :set_restaurant, only: [:show, :edit, :update, :destroy, :menu, :qr_code_png, :qr_code_svg]
  before_action :authorize_owner, only: [:edit, :update, :destroy, :qr_code_png, :qr_code_svg]

  # GET /restaurants
  def index
    @restaurants = Restaurant.all
  end

  # GET /restaurants/:id
  def show
  end

  # GET /restaurants/:id/menu
  def menu
    # Get selected location from params, session, or GPS
    @selected_location = nil
    
    # Priority: 1. URL param, 2. Session, 3. GPS detection
    if params[:location_id].present?
      @selected_location = @restaurant.locations.active.find_by(id: params[:location_id])
      session[:selected_location_id] = @selected_location&.id
    elsif session[:selected_location_id].present?
      @selected_location = @restaurant.locations.active.find_by(id: session[:selected_location_id])
    elsif params[:latitude].present? && params[:longitude].present?
      # GPS coordinates provided
      latitude = params[:latitude].to_f
      longitude = params[:longitude].to_f
      @selected_location = find_nearest_location(@restaurant, latitude, longitude, max_distance_km: 50)
      session[:selected_location_id] = @selected_location&.id if @selected_location
    end
    
    # Get location-specific menu items
    if @selected_location.present?
      # Show location-specific items + general items (no location)
      @menu_items = @restaurant.menu_items.where(
        "(location_id = ? OR location_id IS NULL)",
        @selected_location.id
      ).ordered rescue @restaurant.menu_items.where(
        "(location_id = ? OR location_id IS NULL)",
        @selected_location.id
      ).order(:category, :name)
    else
      # Show only general items (no location)
      begin
        @menu_items = @restaurant.menu_items.where(location_id: nil).ordered
      rescue
        @menu_items = @restaurant.menu_items.where(location_id: nil).order(:category, :name)
      end
    end
    
    # Print mode check
    @print_mode = params[:print] == 'true'
    
    if @print_mode
      # Group by category for print view
      @menu_items_by_category = @menu_items.group_by { |item| item.category || 'Uncategorized' }
      render 'menu_print', layout: 'print'
      return
    end
    
    # Group by category for regular view
    @menu_items_by_category = @menu_items.group_by { |item| item.category || 'Uncategorized' }
    
    # Get available locations for selection
    @available_locations = @restaurant.locations.active.order(:name)
    
    # Get active promotions for this restaurant (if promotions exist)
    @active_promotions = []
    if @restaurant.respond_to?(:promotions)
      begin
        @active_promotions = @restaurant.promotions.active.current.order(start_date: :desc) rescue []
      rescue
        @active_promotions = []
      end
    end
    
    # Get selected language from params or session, default to 'en'
    @current_language = params[:lang] || session[:menu_language] || 'en'
    session[:menu_language] = @current_language
    
    # Get available languages from menu items
    @available_languages = ['en'] # Always include English
    @menu_items.each do |item|
      if item.respond_to?(:name_translations) && item.name_translations.present?
        @available_languages |= item.name_translations.keys.map(&:to_s)
      end
      if item.respond_to?(:description_translations) && item.description_translations.present?
        @available_languages |= item.description_translations.keys.map(&:to_s)
      end
    end
    @available_languages.uniq!
    @available_languages.sort!
    
    # Track QR scan (if qr_scans association exists)
    if @restaurant.respond_to?(:qr_scans)
      begin
        @restaurant.qr_scans.create!(
          scanned_at: Time.current,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )
      rescue => e
        # Silently fail if qr_scans doesn't exist or creation fails
        Rails.logger.debug "QR scan tracking failed: #{e.message}"
      end
    end
    
    # Load active split tests for menu items
    @active_split_tests = {}
    if @restaurant.respond_to?(:split_tests)
      begin
        active_tests = @restaurant.split_tests.active.includes(:split_test_variants, :menu_item)
        active_tests.each do |test|
          if test.menu_item.present?
            @active_split_tests[test.menu_item.id] = test
          end
        end
      rescue
        @active_split_tests = {}
      end
    end
    
    # Track views for menu items
    if @menu_items.any? && @restaurant.respond_to?(:menu_item_analytics)
      begin
        @menu_items.each do |item|
          MenuItemAnalytics.track_view(item, request)
        end
      rescue
        # Silently fail if analytics tracking isn't available
      end
    end
  end

  # GET /restaurants/:id/qr_code_png
  def qr_code_png
    begin
      require 'rqrcode'
      require 'chunky_png'
      
      # Use menu route if available, otherwise use show route
      begin
        menu_url = menu_restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol)
      rescue NoMethodError, NameError
        menu_url = restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol)
      end
      qr = RQRCode::QRCode.new(menu_url)
      
      png = qr.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 600
      )
      
      send_data png.to_s, 
                type: 'image/png', 
                disposition: 'attachment',
                filename: "#{@restaurant.name.parameterize}-menu-qr-code.png"
    rescue LoadError, NameError => e
      redirect_to @restaurant, alert: "QR code generation requires the 'rqrcode' and 'chunky_png' gems. Please install them: bundle add rqrcode chunky_png"
    end
  end

  # GET /restaurants/:id/qr_code_svg
  def qr_code_svg
    begin
      require 'rqrcode'
      
      # Use menu route if available, otherwise use show route
      begin
        menu_url = menu_restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol)
      rescue NoMethodError, NameError
        menu_url = restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol)
      end
      qr = RQRCode::QRCode.new(menu_url)
      
      svg = qr.as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 11,
        standalone: true,
        svg_attributes: {
          width: 600,
          height: 600
        }
      )
      
      send_data svg, 
                type: 'image/svg+xml', 
                disposition: 'attachment',
                filename: "#{@restaurant.name.parameterize}-menu-qr-code.svg"
    rescue LoadError, NameError => e
      redirect_to @restaurant, alert: "QR code generation requires the 'rqrcode' gem. Please install it: bundle add rqrcode"
    end
  end

  # GET /restaurants/new
  def new
    @restaurant = Restaurant.new
  end

  # POST /restaurants
  def create
    @restaurant = Restaurant.new(restaurant_params)
    
    # Assign user if authentication is available
    if respond_to?(:user_signed_in?) && user_signed_in? && respond_to?(:current_user)
      @restaurant.user = current_user
    end

    if @restaurant.save
      redirect_to @restaurant, notice: "Restaurant was successfully created."
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:id/edit
  def edit
  end

  # PATCH/PUT /restaurants/:id
  def update
    if @restaurant.update(restaurant_params)
      redirect_to @restaurant, notice: "Restaurant was successfully updated."
    else
      # Re-render the form with validation errors
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:id
  def destroy
    @restaurant.destroy
    redirect_to restaurants_url, notice: "Restaurant was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  # Require authentication for protected actions
  def require_authentication
    unless respond_to?(:user_signed_in?) && user_signed_in? && respond_to?(:current_user)
      redirect_to restaurants_path, alert: "You must be signed in to perform this action."
      return
    end
  end

  # Authorize that the current user owns the restaurant
  def authorize_owner
    # Check if authentication is available
    unless respond_to?(:user_signed_in?) && user_signed_in? && respond_to?(:current_user)
      redirect_to @restaurant, alert: "You must be signed in to perform this action."
      return
    end

    # Check if restaurant has an owner
    if @restaurant.user.nil?
      redirect_to @restaurant, alert: "This restaurant has no owner. Only restaurant owners can edit or delete restaurants."
      return
    end

    # Check if current user is the owner
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only edit or delete your own restaurants."
      return
    end
  end

  # Only allow a list of trusted parameters through
  def restaurant_params
    params.require(:restaurant).permit(:name, :description, :address, :phone_number, :cuisine)
  end
end
