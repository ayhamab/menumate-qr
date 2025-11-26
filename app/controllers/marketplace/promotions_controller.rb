class Marketplace::PromotionsController < ApplicationController
  def index
    @promotions = SupplierPromotion.active.includes(:supplier)
    
    # Filtering
    @promotions = @promotions.by_type(params[:type]) if params[:type].present?
    @promotions = @promotions.featured if params[:featured] == 'true'
    @promotions = @promotions.joins(:supplier)
                            .where("suppliers.company_name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    
    @promotions = @promotions.order(start_date: :desc).page(params[:page]).per(12)
    @promotion_types = SupplierPromotion.distinct.pluck(:promotion_type)
  end

  def show
    @promotion = SupplierPromotion.active.find(params[:id])
    @supplier = @promotion.supplier
    @related_promotions = @supplier.supplier_promotions.active
                                   .where.not(id: @promotion.id)
                                   .limit(6)
    
    # Track view
    @promotion.increment!(:view_count)
  end
end

