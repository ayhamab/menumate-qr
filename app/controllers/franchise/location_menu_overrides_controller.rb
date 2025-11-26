class Franchise::LocationMenuOverridesController < ApplicationController
  before_action :set_corporate_account
  before_action :set_menu_template
  before_action :require_corporate_access
  before_action :set_override, only: [:show, :edit, :update, :approve, :reject]

  def index
    @overrides = @menu_template.location_menu_overrides.includes(:location, :menu_template_item).recent
    @overrides = @overrides.where(status: params[:status]) if params[:status].present?
    @overrides = @overrides.where(location_id: params[:location_id]) if params[:location_id].present?
  end

  def show
  end

  def new
    @override = @menu_template.location_menu_overrides.build(
      status: 'pending',
      created_by: current_user
    )
    @locations = @corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    @template_items = @menu_template.menu_template_items.active
  end

  def create
    @override = @menu_template.location_menu_overrides.build(override_params)
    @override.created_by = current_user
    
    if @override.save
      redirect_to franchise_menu_template_location_menu_override_path(@menu_template, @override), 
                  notice: "Override request created. Waiting for approval."
    else
      @locations = @corporate_account.restaurants.includes(:locations).flat_map(&:locations)
      @template_items = @menu_template.menu_template_items.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @locations = @corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    @template_items = @menu_template.menu_template_items.active
  end

  def update
    if @override.update(override_params)
      redirect_to franchise_menu_template_location_menu_override_path(@menu_template, @override), 
                  notice: "Override updated."
    else
      @locations = @corporate_account.restaurants.includes(:locations).flat_map(&:locations)
      @template_items = @menu_template.menu_template_items.active
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    if can_approve_overrides?
      @override.approve!(current_user)
      
      # Apply override to menu item if applicable
      if @override.menu_template_item
        location_item = @override.location.restaurant.menu_items.find_by(
          name: @override.menu_template_item.name,
          location: @override.location
        )
        @override.apply_to_menu_item(location_item) if location_item
      end
      
      redirect_to franchise_menu_template_location_menu_overrides_path(@menu_template), 
                  notice: "Override approved."
    else
      redirect_to franchise_menu_template_location_menu_override_path(@menu_template, @override), 
                  alert: "You don't have permission to approve overrides."
    end
  end

  def reject
    if can_approve_overrides?
      @override.reject!(current_user, params[:rejection_reason])
      redirect_to franchise_menu_template_location_menu_overrides_path(@menu_template), 
                  notice: "Override rejected."
    else
      redirect_to franchise_menu_template_location_menu_override_path(@menu_template, @override), 
                  alert: "You don't have permission to reject overrides."
    end
  end

  private

  def set_corporate_account
    @corporate_account = CorporateAccount.find(params[:corporate_account_id]) if params[:corporate_account_id].present?
    @corporate_account ||= current_user&.corporate_accounts&.first
    
    unless @corporate_account
      redirect_to root_path, alert: "Corporate account not found."
    end
  end

  def set_menu_template
    @menu_template = @corporate_account.menu_templates.find(params[:menu_template_id])
  end

  def set_override
    @override = @menu_template.location_menu_overrides.find(params[:id])
  end

  def require_corporate_access
    unless can_access_corporate_account?(@corporate_account)
      redirect_to root_path, alert: "You don't have access to this corporate account."
    end
  end

  def can_access_corporate_account?(account)
    return false unless respond_to?(:current_user) && current_user
    account.corporate_account_users.active.exists?(user: current_user)
  end

  def can_approve_overrides?
    return false unless respond_to?(:current_user) && current_user
    role = @corporate_account.corporate_account_users.find_by(user: current_user)&.role
    %w[admin manager].include?(role)
  end

  def override_params
    params.require(:location_menu_override).permit(
      :menu_template_item_id, :location_id, :action, :reason,
      override_attributes: {}
    )
  end
end

