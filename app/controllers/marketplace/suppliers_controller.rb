class Marketplace::SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show]

  def index
    @suppliers = Supplier.active.verified
    
    # Filtering
    @suppliers = @suppliers.where(business_type: params[:business_type]) if params[:business_type].present?
    @suppliers = @suppliers.where("company_name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @suppliers = @suppliers.where("city ILIKE ?", "%#{params[:location]}%") if params[:location].present?
    
    # Sorting
    case params[:sort]
    when 'featured'
      @suppliers = @suppliers.featured.recent
    when 'rating'
      @suppliers = @suppliers.joins(:supplier_reviews)
                            .group('suppliers.id')
                            .order('AVG(supplier_reviews.rating) DESC')
    when 'newest'
      @suppliers = @suppliers.recent
    else
      @suppliers = @suppliers.featured.recent
    end
    
    @suppliers = @suppliers.page(params[:page]).per(12)
    @business_types = Supplier.distinct.pluck(:business_type).compact
  end

  def show
    @ingredient_listings = @supplier.ingredient_listings.active.includes(:categories).recent.limit(12)
    @active_promotions = @supplier.supplier_promotions.active
    @reviews = @supplier.supplier_reviews.approved.recent.limit(10)
    @average_rating = @supplier.average_rating
  end

  def contact
    @supplier = Supplier.find(params[:id])
    @restaurant = current_user&.restaurants&.first if respond_to?(:current_user) && current_user
    
    @contact = @supplier.supplier_contacts.build(
      restaurant: @restaurant,
      contact_type: params[:contact_type] || 'general',
      name: @restaurant&.user&.email || params[:name],
      email: @restaurant&.user&.email || params[:email]
    )
    
    if request.post?
      @contact = @supplier.supplier_contacts.build(contact_params)
      @contact.restaurant = @restaurant if @restaurant
      
      if @contact.save
        redirect_to marketplace_supplier_path(@supplier), notice: "Your message has been sent to #{@supplier.company_name}."
      else
        render :contact, status: :unprocessable_entity
      end
    end
  end

  private

  def set_supplier
    @supplier = Supplier.active.verified.find(params[:id])
  end

  def contact_params
    params.require(:supplier_contact).permit(:contact_type, :name, :email, :phone_number, :message, :ingredient_listing_id)
  end
end

