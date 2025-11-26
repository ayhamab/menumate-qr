class DietaryAccuracyReportsController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu_item, only: [:create]
  before_action :authenticate_user!, only: [:index]
  before_action :authorize_owner, only: [:index]

  # POST /restaurants/:restaurant_id/menu_items/:menu_item_id/dietary-reports
  def create
    @report = @menu_item.dietary_accuracy_reports.build(report_params)
    @report.ip_address = request.remote_ip
    @report.user_agent = request.user_agent

    respond_to do |format|
      if @report.save
        format.html { redirect_to menu_restaurant_path(@restaurant), notice: "Thank you for reporting this issue. We'll review it promptly." }
        format.turbo_stream { render :create }
        format.json { render json: { status: 'success', message: 'Report submitted successfully' } }
      else
        format.html { redirect_to menu_restaurant_path(@restaurant), alert: "Unable to submit report. #{@report.errors.full_messages.join(', ')}" }
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.json { render json: { status: 'error', errors: @report.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # GET /restaurants/:restaurant_id/menu_items/:menu_item_id/dietary-reports
  def index
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
    @reports = @menu_item.dietary_accuracy_reports.recent
    @unresolved_count = @menu_item.dietary_accuracy_reports.unresolved.count
  end

  # PATCH /restaurants/:restaurant_id/menu_items/:menu_item_id/dietary-reports/:id/resolve
  def resolve
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
    @report = @menu_item.dietary_accuracy_reports.find(params[:id])
    
    if @report.update(resolve_params)
      redirect_to restaurant_menu_item_dietary_accuracy_reports_path(@restaurant, @menu_item), notice: "Report marked as resolved."
    else
      redirect_to restaurant_menu_item_dietary_accuracy_reports_path(@restaurant, @menu_item), alert: "Unable to resolve report."
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

  def authorize_owner
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only view reports for your own restaurants."
      return
    end
  end

  def report_params
    params.require(:dietary_accuracy_report).permit(:issue_type, :description, :reported_by)
  end

  def resolve_params
    params.require(:dietary_accuracy_report).permit(:resolved, :resolution_notes)
  end
end
