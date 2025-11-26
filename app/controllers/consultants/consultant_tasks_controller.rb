class Consultants::ConsultantTasksController < ApplicationController
  before_action :authenticate_consultant! if respond_to?(:authenticate_consultant!)
  before_action :set_consultant
  before_action :set_task, only: [:update, :destroy, :complete, :start]

  def index
    @tasks = @consultant.consultant_tasks.includes(:restaurant, :menu_item).recent
    @tasks = @tasks.by_restaurant(Restaurant.find(params[:restaurant_id])) if params[:restaurant_id].present?
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.by_priority(params[:priority]) if params[:priority].present?
  end

  def create
    @task = @consultant.consultant_tasks.build(task_params)
    
    if @task.save
      redirect_back(fallback_location: consultants_tasks_path, notice: "Task created successfully.")
    else
      redirect_back(fallback_location: consultants_tasks_path, alert: "Error creating task.")
    end
  end

  def update
    if @task.update(task_params)
      redirect_back(fallback_location: consultants_tasks_path, notice: "Task updated successfully.")
    else
      redirect_back(fallback_location: consultants_tasks_path, alert: "Error updating task.")
    end
  end

  def destroy
    @task.destroy
    redirect_back(fallback_location: consultants_tasks_path, notice: "Task deleted.")
  end

  def complete
    @task.update(status: 'completed', completed_at: Time.current)
    redirect_back(fallback_location: consultants_tasks_path, notice: "Task marked as completed.")
  end

  def start
    @task.update(status: 'in_progress')
    redirect_back(fallback_location: consultants_tasks_path, notice: "Task started.")
  end

  private

  def set_consultant
    @consultant = respond_to?(:current_consultant) ? current_consultant : nil
    return redirect_to new_consultant_session_path, alert: "Please sign in." unless @consultant
  end

  def set_task
    @task = @consultant.consultant_tasks.find(params[:id])
  end

  def task_params
    params.require(:consultant_task).permit(:restaurant_id, :menu_item_id, :task_type, :title, :description, 
                                            :status, :priority, :due_date, :notes)
  end
end

