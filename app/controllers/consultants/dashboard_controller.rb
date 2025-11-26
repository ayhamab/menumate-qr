class Consultants::DashboardController < ApplicationController
  before_action :authenticate_consultant! if respond_to?(:authenticate_consultant!)

  def index
    @consultant = respond_to?(:current_consultant) ? current_consultant : nil
    return redirect_to new_consultant_session_path, alert: "Please sign in." unless @consultant
    
    @clients = @consultant.consultant_clients.active.includes(:restaurant).recent.limit(10)
    @recent_tasks = @consultant.consultant_tasks.where.not(status: 'completed').recent.limit(10)
    @overdue_tasks = @consultant.consultant_tasks.overdue
    @urgent_tasks = @consultant.consultant_tasks.urgent.where.not(status: ['completed', 'cancelled'])
    @recent_notes = @consultant.consultant_notes.recent.limit(10)
    @pinned_notes = @consultant.consultant_notes.pinned
    
    @stats = {
      total_clients: @consultant.client_count,
      active_clients: @consultant.active_client_count,
      total_menu_items: @consultant.total_menu_items_managed,
      pending_tasks: @consultant.consultant_tasks.pending.count,
      overdue_tasks: @overdue_tasks.count,
      urgent_tasks: @urgent_tasks.count,
      completed_tasks_this_month: @consultant.consultant_tasks.completed
                                                      .where('completed_at >= ?', Date.current.beginning_of_month)
                                                      .count,
      recent_reports: @consultant.consultant_reports.recent.limit(5).count
    }
  end
end

