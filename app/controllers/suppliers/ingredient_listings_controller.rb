class Suppliers::IngredientListingsController < ApplicationController
  before_action :authenticate_supplier! if respond_to?(:authenticate_supplier!)
  before_action :set_ingredient_listing, only: [:show, :edit, :update, :destroy]

  def index
    supplier = respond_to?(:current_supplier) ? current_supplier : nil
    return redirect_to new_supplier_session_path, alert: "Please sign in." unless supplier
    @ingredient_listings = supplier.ingredient_listings.includes(:categories).recent
    @ingredient_listings = @ingredient_listings.where(status: params[:status]) if params[:status].present?
  end

  def show
  end

  def new
    supplier = respond_to?(:current_supplier) ? current_supplier : nil
    return redirect_to new_supplier_session_path, alert: "Please sign in." unless supplier
    @ingredient_listing = supplier.ingredient_listings.build
    @categories = Category.active.ordered
  end

  def create
    supplier = respond_to?(:current_supplier) ? current_supplier : nil
    return redirect_to new_supplier_session_path, alert: "Please sign in." unless supplier
    @ingredient_listing = supplier.ingredient_listings.build(ingredient_listing_params)

    if @ingredient_listing.save
      # Handle category associations
      if params[:category_ids].present?
        @ingredient_listing.category_ids = params[:category_ids]
      end
      redirect_to suppliers_ingredient_listing_path(@ingredient_listing), notice: "Ingredient listing created successfully."
    else
      @categories = Category.active.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.active.ordered
  end

  def update
    if @ingredient_listing.update(ingredient_listing_params)
      # Handle category associations
      if params[:category_ids].present?
        @ingredient_listing.category_ids = params[:category_ids]
      end
      redirect_to suppliers_ingredient_listing_path(@ingredient_listing), notice: "Ingredient listing updated successfully."
    else
      @categories = Category.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient_listing.destroy
    redirect_to suppliers_ingredient_listings_path, notice: "Ingredient listing deleted."
  end

  private

  def set_ingredient_listing
    supplier = respond_to?(:current_supplier) ? current_supplier : nil
    return redirect_to new_supplier_session_path, alert: "Please sign in." unless supplier
    @ingredient_listing = supplier.ingredient_listings.find(params[:id])
  end

  def ingredient_listing_params
    params.require(:ingredient_listing).permit(
      :name, :description, :price_per_unit, :unit, :minimum_order_quantity,
      :minimum_order_amount, :in_stock, :local, :organic, :featured, :status,
      :storage_requirements, :shelf_life, :packaging_info,
      dietary_info: [], certifications: []
    )
  end
end

