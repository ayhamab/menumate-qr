class Admin::BrandAnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_access
  before_action :set_brand_analytic, only: [:show, :edit, :update, :destroy, :regenerate_api_key, :toggle_active]

  # GET /admin/brand_analytics
  def index
    @brand_analytics = BrandAnalytic.order(created_at: :desc)
    @brand_analytics = @brand_analytics.where(subscription_tier: params[:tier]) if params[:tier].present?
    @brand_analytics = @brand_analytics.where(active: params[:active] == 'true') if params[:active].present?
  end

  # GET /admin/brand_analytics/:id
  def show
  end

  # GET /admin/brand_analytics/new
  def new
    @brand_analytic = BrandAnalytic.new
  end

  # POST /admin/brand_analytics
  def create
    @brand_analytic = BrandAnalytic.new(brand_analytic_params)

    if @brand_analytic.save
      redirect_to admin_brand_analytic_path(@brand_analytic), notice: "Brand analytics account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/brand_analytics/:id/edit
  def edit
  end

  # PATCH/PUT /admin/brand_analytics/:id
  def update
    if @brand_analytic.update(brand_analytic_params)
      redirect_to admin_brand_analytic_path(@brand_analytic), notice: "Brand analytics account updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/brand_analytics/:id
  def destroy
    @brand_analytic.destroy
    redirect_to admin_brand_analytics_path, notice: "Brand analytics account deleted successfully."
  end

  # POST /admin/brand_analytics/:id/regenerate_api_key
  def regenerate_api_key
    @brand_analytic.update(api_key: SecureRandom.hex(32))
    redirect_to admin_brand_analytic_path(@brand_analytic), notice: "API key regenerated successfully."
  end

  # PATCH /admin/brand_analytics/:id/toggle_active
  def toggle_active
    @brand_analytic.update(active: !@brand_analytic.active)
    status = @brand_analytic.active? ? 'activated' : 'deactivated'
    redirect_to admin_brand_analytic_path(@brand_analytic), notice: "Brand analytics account #{status}."
  end

  private

  def set_brand_analytic
    @brand_analytic = BrandAnalytic.find(params[:id])
  end

  def check_admin_access
    # For now, allow any authenticated user. In production, add admin role check
    unless user_signed_in?
      redirect_to root_path, alert: "Admin access required."
      return
    end
  end

  def brand_analytic_params
    params.require(:brand_analytic).permit(:brand_name, :email, :subscription_tier, :active, :notes, :monthly_fee)
  end
end
