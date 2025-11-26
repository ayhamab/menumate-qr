class Marketplace::IngredientListingsController < ApplicationController
  before_action :set_supplier
  before_action :set_ingredient_listing, only: [:show, :contact]

  def index
    @ingredient_listings = @supplier.ingredient_listings.active.includes(:categories, :supplier)
    
    # Filtering
    @ingredient_listings = @ingredient_listings.by_category(params[:category]) if params[:category].present?
    @ingredient_listings = @ingredient_listings.organic if params[:organic] == 'true'
    @ingredient_listings = @ingredient_listings.local if params[:local] == 'true'
    @ingredient_listings = @ingredient_listings.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    
    @ingredient_listings = @ingredient_listings.page(params[:page]).per(20)
  end

  def show
    # Track view
    @ingredient_listing.increment!(:view_count)
    
    @supplier = @ingredient_listing.supplier
    @related_listings = @supplier.ingredient_listings.active
                                  .where.not(id: @ingredient_listing.id)
                                  .limit(6)
    @restaurant = current_user&.restaurants&.first if respond_to?(:current_user) && current_user
  end

  def contact
    @restaurant = current_user&.restaurants&.first if respond_to?(:current_user) && current_user
    
    @contact = @supplier.supplier_contacts.build(
      restaurant: @restaurant,
      ingredient_listing: @ingredient_listing,
      contact_type: 'inquiry',
      name: @restaurant&.user&.email || params[:name],
      email: @restaurant&.user&.email || params[:email]
    )
    
    if request.post?
      @contact = @supplier.supplier_contacts.build(contact_params)
      @contact.restaurant = @restaurant if @restaurant
      @contact.ingredient_listing = @ingredient_listing
      
      if @contact.save
        @ingredient_listing.increment!(:contact_count)
        redirect_to marketplace_supplier_ingredient_listing_path(@supplier, @ingredient_listing), 
                    notice: "Your inquiry has been sent to #{@supplier.company_name}."
      else
        render :contact, status: :unprocessable_entity
      end
    end
  end

  private

  def set_supplier
    @supplier = Supplier.active.verified.find(params[:supplier_id])
  end

  def set_ingredient_listing
    @ingredient_listing = @supplier.ingredient_listings.active.find(params[:id])
  end

  def contact_params
    params.require(:supplier_contact).permit(:contact_type, :name, :email, :phone_number, :message)
  end
end

