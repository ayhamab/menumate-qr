class Franchise::MenuConsistencyReportsController < ApplicationController
  before_action :set_corporate_account
  before_action :require_corporate_access
  before_action :set_report, only: [:show]

  def index
    @reports = @corporate_account.menu_consistency_reports.recent
    @reports = @reports.where(report_type: params[:type]) if params[:type].present?
  end

  def show
  end

  def create
    report = @corporate_account.menu_consistency_reports.build(
      report_type: params[:report_type] || 'full',
      menu_template_id: params[:menu_template_id],
      generated_by: current_user
    )
    
    report.generate!
    
    redirect_to franchise_menu_consistency_report_path(report), 
                notice: "Consistency report generated successfully."
  end

  def generate
    report = @corporate_account.menu_consistency_reports.build(
      report_type: params[:report_type] || 'full',
      menu_template_id: params[:menu_template_id],
      generated_by: current_user
    )
    
    report.generate!
    
    redirect_to franchise_menu_consistency_reports_path, 
                notice: "Report generated successfully."
  end

  private

  def set_corporate_account
    @corporate_account = CorporateAccount.find(params[:corporate_account_id]) if params[:corporate_account_id].present?
    @corporate_account ||= current_user&.corporate_accounts&.first
    
    unless @corporate_account
      redirect_to root_path, alert: "Corporate account not found."
    end
  end

  def set_report
    @report = @corporate_account.menu_consistency_reports.find(params[:id])
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
end

