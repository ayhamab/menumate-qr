class Suppliers::DashboardController < ApplicationController
  before_action :authenticate_supplier! if respond_to?(:authenticate_supplier!)

  def index
    @supplier = respond_to?(:current_supplier) ? current_supplier : nil
    return redirect_to new_supplier_session_path, alert: "Please sign in." unless @supplier
    
    @ingredient_listings = @supplier.ingredient_listings.recent.limit(5)
    @active_promotions = @supplier.supplier_promotions.active.limit(5)
    @recent_contacts = @supplier.supplier_contacts.unread.recent.limit(5)
    @stats = {
      total_listings: @supplier.ingredient_listings.count,
      active_listings: @supplier.ingredient_listings.active.count,
      total_contacts: @supplier.supplier_contacts.count,
      unread_contacts: @supplier.supplier_contacts.unread.count,
      active_promotions: @supplier.supplier_promotions.active.count,
      total_views: @supplier.ingredient_listings.sum(:view_count)
    }
  end
end

