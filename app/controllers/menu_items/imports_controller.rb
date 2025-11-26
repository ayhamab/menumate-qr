class MenuItems::ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :authorize_owner

  # GET /restaurants/:restaurant_id/menu_items/imports/new
  def new
    @sample_csv = generate_sample_csv
  end

  # GET /restaurants/:restaurant_id/menu_items/imports.csv
  def show
    respond_to do |format|
      format.csv do
        send_data generate_sample_csv,
                  filename: "menu_items_sample_#{Date.current.strftime('%Y%m%d')}.csv",
                  type: 'text/csv'
      end
    end
  end

  # POST /restaurants/:restaurant_id/menu_items/imports
  def create
    unless params[:csv_file].present?
      redirect_to new_restaurant_menu_items_import_path(@restaurant), 
                  alert: "Please select a CSV file to upload."
      return
    end

    # Check subscription limits
    current_count = @restaurant.menu_items.count
    csv_file = params[:csv_file]
    
    begin
      # Parse CSV to count rows
      csv_data = CSV.read(csv_file.path, headers: true)
      new_items_count = csv_data.count
      
      unless @restaurant.within_limits?(:menu_items, current_count + new_items_count)
        redirect_to new_restaurant_menu_items_import_path(@restaurant), 
                    alert: "Import would exceed your plan's menu item limit (#{current_count + new_items_count} items). Please upgrade your subscription or reduce the number of items in your CSV."
        return
      end

      # Import CSV
      importer = MenuItemCsvImporter.new(@restaurant, csv_file)
      result = importer.import

      if result[:success]
        redirect_to restaurant_menu_items_path(@restaurant), 
                    notice: "Successfully imported #{result[:imported]} menu items. #{result[:errors].any? ? "#{result[:errors].count} items had errors." : ''}"
      else
        @errors = result[:errors]
        @sample_csv = generate_sample_csv
        render :new, status: :unprocessable_entity
      end
    rescue CSV::MalformedCSVError => e
      redirect_to new_restaurant_menu_items_import_path(@restaurant), 
                  alert: "Invalid CSV file format: #{e.message}"
    rescue => e
      redirect_to new_restaurant_menu_items_import_path(@restaurant), 
                  alert: "Error importing CSV: #{e.message}"
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def authorize_owner
    unless @restaurant.user == current_user || (@restaurant.corporate_account&.has_user?(current_user) && @restaurant.corporate_account.can_manage?(current_user))
      redirect_to restaurants_path, alert: "You don't have permission to manage this restaurant."
    end
  end

  def generate_sample_csv
    CSV.generate(headers: true) do |csv|
      csv << ['name', 'description', 'price', 'category', 'dietary_tags', 'allergens', 'position']
      csv << ['Caesar Salad', 'Fresh romaine lettuce with caesar dressing', '12.99', 'Salads', 'vegetarian', 'dairy', '1']
      csv << ['Grilled Chicken', 'Tender grilled chicken breast with vegetables', '18.99', 'Main Courses', 'gluten-free', '', '2']
      csv << ['Chocolate Cake', 'Rich chocolate cake with vanilla ice cream', '8.99', 'Desserts', 'vegetarian', 'dairy,eggs', '3']
    end
  end
end
