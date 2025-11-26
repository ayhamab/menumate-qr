class Franchise::MenuTemplatesController < ApplicationController
  before_action :set_corporate_account
  before_action :require_corporate_access
  before_action :set_menu_template, only: [:show, :edit, :update, :destroy, :activate, :archive, :create_version, :sync_to_locations]

  def index
    @menu_templates = @corporate_account.menu_templates.includes(:menu_template_items).recent
    @menu_templates = @menu_templates.where(status: params[:status]) if params[:status].present?
    
    @stats = {
      total_templates: @menu_templates.count,
      active_templates: @menu_templates.active.count,
      draft_templates: @menu_templates.draft.count,
      total_locations: @corporate_account.restaurants.includes(:locations).flat_map(&:locations).count
    }
  end

  def show
    @menu_template_items = @menu_template.menu_template_items.ordered
    @menu_syncs = @menu_template.menu_syncs.recent.limit(10)
    @location_overrides = @menu_template.location_menu_overrides.pending.limit(10)
    @consistency_report = @menu_template.consistency_report
  end

  def new
    @menu_template = @corporate_account.menu_templates.build(
      version: '1.0.0',
      status: 'draft'
    )
  end

  def create
    @menu_template = @corporate_account.menu_templates.build(menu_template_params)
    
    if @menu_template.save
      redirect_to franchise_menu_template_path(@menu_template), 
                  notice: "Menu template created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_template.update(menu_template_params)
      redirect_to franchise_menu_template_path(@menu_template), 
                  notice: "Menu template updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @menu_template.draft?
      @menu_template.destroy
      redirect_to franchise_menu_templates_path, 
                  notice: "Menu template deleted."
    else
      redirect_to franchise_menu_template_path(@menu_template), 
                  alert: "Only draft templates can be deleted."
    end
  end

  def activate
    if @menu_template.draft?
      # Archive previous active template
      @corporate_account.menu_templates.active.update_all(status: 'archived')
      
      @menu_template.update(status: 'active')
      redirect_to franchise_menu_template_path(@menu_template), 
                  notice: "Menu template activated."
    else
      redirect_to franchise_menu_template_path(@menu_template), 
                  alert: "Only draft templates can be activated."
    end
  end

  def archive
    if @menu_template.active?
      @menu_template.update(status: 'archived')
      redirect_to franchise_menu_templates_path, 
                  notice: "Menu template archived."
    else
      redirect_to franchise_menu_template_path(@menu_template), 
                  alert: "Only active templates can be archived."
    end
  end

  def create_version
    new_template = @menu_template.create_new_version
    
    redirect_to edit_franchise_menu_template_path(new_template), 
                notice: "New version created. You can now edit it."
  end

  def sync_to_locations
    location_ids = params[:location_ids]&.map(&:to_i)
    
    if location_ids.present?
      syncs = MenuSyncService.sync_template_to_selected_locations(@menu_template, location_ids)
    else
      syncs = MenuSyncService.sync_template_to_all_locations(@menu_template)
    end
    
    redirect_to franchise_menu_template_path(@menu_template), 
                notice: "Initiated sync to #{syncs.count} locations."
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
    @menu_template = @corporate_account.menu_templates.find(params[:id])
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

  def menu_template_params
    params.require(:menu_template).permit(:name, :version, :status, :description, :effective_date, :expiry_date, settings: {})
  end
end

