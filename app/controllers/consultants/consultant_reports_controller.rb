class Consultants::ConsultantReportsController < ApplicationController
  before_action :authenticate_consultant! if respond_to?(:authenticate_consultant!)
  before_action :set_consultant
  before_action :set_report, only: [:show, :update, :destroy, :share]

  def index
    @reports = @consultant.consultant_reports.includes(:restaurant).recent
    @reports = @reports.by_restaurant(Restaurant.find(params[:restaurant_id])) if params[:restaurant_id].present?
    @reports = @reports.by_type(params[:report_type]) if params[:report_type].present?
  end

  def show
    @restaurant = @report.restaurant
  end

  def create
    @report = @consultant.consultant_reports.build(report_params)
    
    if @report.save
      redirect_to consultants_report_path(@report), notice: "Report created successfully."
    else
      redirect_back(fallback_location: consultants_reports_path, alert: "Error creating report.")
    end
  end

  def update
    if @report.update(report_params)
      redirect_to consultants_report_path(@report), notice: "Report updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy
    redirect_to consultants_reports_path, notice: "Report deleted."
  end

  def share
    @report.update(shared_with_restaurant: true, shared_at: Time.current)
    redirect_to consultants_report_path(@report), notice: "Report shared with restaurant."
  end

  private

  def set_consultant
    @consultant = respond_to?(:current_consultant) ? current_consultant : nil
    return redirect_to new_consultant_session_path, alert: "Please sign in." unless @consultant
  end

  def set_report
    @report = @consultant.consultant_reports.find(params[:id])
  end

  def report_params
    params.require(:consultant_report).permit(:restaurant_id, :report_type, :title, :content, 
                                               findings: [], recommendations: [])
  end
end

