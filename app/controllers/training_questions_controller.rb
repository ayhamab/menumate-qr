class TrainingQuestionsController < ApplicationController
  before_action :set_restaurant
  before_action :set_training_module
  before_action :require_team_access
  before_action :require_edit_permission
  before_action :set_training_question, only: [:edit, :update, :destroy]

  # GET /restaurants/:restaurant_id/training_modules/:training_module_id/training_questions
  def index
    @training_questions = @training_module.training_questions.ordered
  end

  # GET /restaurants/:restaurant_id/training_modules/:training_module_id/training_questions/new
  def new
    @training_question = @training_module.training_questions.build(
      question_type: 'multiple_choice',
      position: @training_module.training_questions.maximum(:position).to_i + 1
    )
    # Initialize options for display
    @training_question.options ||= []
  end

  # POST /restaurants/:restaurant_id/training_modules/:training_module_id/training_questions
  def create
    @training_question = @training_module.training_questions.build
    
    # Process options from text area
    if params[:training_question][:options_text].present?
      options = params[:training_question][:options_text].split("\n").map(&:strip).reject(&:blank?)
      @training_question.options = options
    else
      @training_question.options = params[:training_question][:options] || []
    end
    
    # Process correct option
    if params[:training_question][:correct_option_text].present?
      correct_text = params[:training_question][:correct_option_text].strip
      if correct_text.include?(',')
        # Multiple select - array
        @training_question.correct_option = correct_text.split(',').map(&:strip).map(&:to_i)
      else
        # Single select - number
        @training_question.correct_option = correct_text.to_i
      end
    else
      correct_option = params[:training_question][:correct_option]
      if correct_option.is_a?(Array)
        @training_question.correct_option = correct_option.map(&:to_i)
      else
        @training_question.correct_option = correct_option.to_i
      end
    end
    
    # Set other attributes
    @training_question.question_text = params[:training_question][:question_text]
    @training_question.question_type = params[:training_question][:question_type]
    @training_question.explanation = params[:training_question][:explanation]
    @training_question.hint = params[:training_question][:hint]
    @training_question.position = params[:training_question][:position] || 0

    if @training_question.save
      redirect_to restaurant_training_module_path(@restaurant, @training_module), notice: "Question added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/training_modules/:training_module_id/training_questions/:id/edit
  def edit
    # Prepare options text for editing
    @options_text = @training_question.options&.join("\n") || ""
    @correct_option_text = if @training_question.correct_option.is_a?(Array)
      @training_question.correct_option.join(',')
    else
      @training_question.correct_option.to_s
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/training_modules/:training_module_id/training_questions/:id
  def update
    # Process options from text area
    if params[:training_question][:options_text].present?
      options = params[:training_question][:options_text].split("\n").map(&:strip).reject(&:blank?)
      @training_question.options = options
    else
      @training_question.options = params[:training_question][:options] || []
    end
    
    # Process correct option
    if params[:training_question][:correct_option_text].present?
      correct_text = params[:training_question][:correct_option_text].strip
      if correct_text.include?(',')
        # Multiple select
        @training_question.correct_option = correct_text.split(',').map(&:strip).map(&:to_i)
      else
        # Single select
        @training_question.correct_option = correct_text.to_i
      end
    else
      correct_option = params[:training_question][:correct_option]
      if correct_option.is_a?(Array)
        @training_question.correct_option = correct_option.map(&:to_i)
      else
        @training_question.correct_option = correct_option.to_i
      end
    end
    
    # Update other attributes
    @training_question.question_text = params[:training_question][:question_text]
    @training_question.question_type = params[:training_question][:question_type]
    @training_question.explanation = params[:training_question][:explanation]
    @training_question.hint = params[:training_question][:hint]
    @training_question.position = params[:training_question][:position] || 0

    if @training_question.save
      redirect_to restaurant_training_module_path(@restaurant, @training_module), notice: "Question updated successfully."
    else
      @options_text = @training_question.options&.join("\n") || ""
      @correct_option_text = if @training_question.correct_option.is_a?(Array)
        @training_question.correct_option.join(',')
      else
        @training_question.correct_option.to_s
      end
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/training_modules/:training_module_id/training_questions/:id
  def destroy
    if @training_question.destroy
      redirect_to restaurant_training_module_path(@restaurant, @training_module), notice: "Question deleted."
    else
      redirect_to restaurant_training_module_path(@restaurant, @training_module), alert: "Could not delete question."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_training_module
    @training_module = @restaurant.training_modules.find(params[:training_module_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_training_modules_path(@restaurant), alert: "Training module not found."
  end

  def set_training_question
    @training_question = @training_module.training_questions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_training_module_path(@restaurant, @training_module), alert: "Question not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_training_modules_path(@restaurant), alert: "You don't have permission to manage training questions."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def training_question_params
    params.require(:training_question).permit(:question_text, :question_type, :position, :explanation, :hint, options: [], correct_option: [])
  end
end

