class Consultants::ClientsController < ApplicationController
  before_action :authenticate_consultant! if respond_to?(:authenticate_consultant!)
  before_action :set_consultant
  before_action :set_client, only: [:show, :edit, :update, :pause, :activate, :terminate]

  def index
    @clients = @consultant.consultant_clients.includes(:restaurant)
    @clients = @clients.where(status: params[:status]) if params[:status].present?
    @clients = @clients.recent
  end

  def show
    @restaurant = @client.restaurant
    @recent_notes = @consultant.consultant_notes.by_restaurant(@restaurant).recent.limit(5)
    @active_tasks = @consultant.consultant_tasks.by_restaurant(@restaurant)
                               .where.not(status: ['completed', 'cancelled'])
                               .recent
    @recent_reports = @consultant.consultant_reports.by_restaurant(@restaurant).recent.limit(5)
  end

  def new
    @client = @consultant.consultant_clients.build(
      can_view: true,
      can_view_analytics: true,
      status: 'active',
      start_date: Date.current
    )
    @available_restaurants = Restaurant.where.not(id: @consultant.restaurants.pluck(:id))
  end

  def create
    @client = @consultant.consultant_clients.build(client_params)
    @client.start_date ||= Date.current
    
    if @client.save
      redirect_to consultants_client_path(@client), notice: "Client added successfully."
    else
      @available_restaurants = Restaurant.where.not(id: @consultant.restaurants.pluck(:id))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to consultants_client_path(@client), notice: "Client updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def pause
    @client.update(status: 'paused')
    redirect_to consultants_client_path(@client), notice: "Client relationship paused."
  end

  def activate
    @client.update(status: 'active')
    redirect_to consultants_client_path(@client), notice: "Client relationship activated."
  end

  def terminate
    @client.update(status: 'terminated', end_date: Date.current)
    redirect_to consultants_clients_path, notice: "Client relationship terminated."
  end

  private

  def set_consultant
    @consultant = respond_to?(:current_consultant) ? current_consultant : nil
    return redirect_to new_consultant_session_path, alert: "Please sign in." unless @consultant
  end

  def set_client
    @client = @consultant.consultant_clients.find(params[:id])
  end

  def client_params
    params.require(:consultant_client).permit(
      :restaurant_id, :can_view, :can_edit_menu, :can_edit_settings,
      :can_manage_team, :can_view_analytics, :status, :start_date, :end_date,
      :notes, :monthly_fee, :contract_type
    )
  end
end

