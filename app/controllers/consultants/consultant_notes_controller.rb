class Consultants::ConsultantNotesController < ApplicationController
  before_action :authenticate_consultant! if respond_to?(:authenticate_consultant!)
  before_action :set_consultant
  before_action :set_note, only: [:update, :destroy]

  def index
    @notes = @consultant.consultant_notes.includes(:restaurant, :menu_item).recent
    @notes = @notes.by_restaurant(Restaurant.find(params[:restaurant_id])) if params[:restaurant_id].present?
    @notes = @notes.by_type(params[:note_type]) if params[:note_type].present?
  end

  def create
    @note = @consultant.consultant_notes.build(note_params)
    
    if @note.save
      redirect_back(fallback_location: consultants_notes_path, notice: "Note created successfully.")
    else
      redirect_back(fallback_location: consultants_notes_path, alert: "Error creating note.")
    end
  end

  def update
    if @note.update(note_params)
      redirect_back(fallback_location: consultants_notes_path, notice: "Note updated successfully.")
    else
      redirect_back(fallback_location: consultants_notes_path, alert: "Error updating note.")
    end
  end

  def destroy
    @note.destroy
    redirect_back(fallback_location: consultants_notes_path, notice: "Note deleted.")
  end

  private

  def set_consultant
    @consultant = respond_to?(:current_consultant) ? current_consultant : nil
    return redirect_to new_consultant_session_path, alert: "Please sign in." unless @consultant
  end

  def set_note
    @note = @consultant.consultant_notes.find(params[:id])
  end

  def note_params
    params.require(:consultant_note).permit(:restaurant_id, :menu_item_id, :note_type, :content, :pinned, tags: [])
  end
end

