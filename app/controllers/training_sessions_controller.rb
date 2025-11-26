class TrainingSessionsController < ApplicationController
  before_action :set_restaurant
  before_action :set_training_module
  before_action :require_team_access
  before_action :set_training_session, only: [:show, :update, :submit, :answer]

  # POST /restaurants/:restaurant_id/training_modules/:training_module_id/training_sessions
  def create
    unless respond_to?(:current_user) && current_user
      redirect_to restaurant_training_module_path(@restaurant, @training_module), alert: "You must be signed in to start training."
      return
    end

    @training_session = TrainingSession.find_or_initialize_by(
      training_module: @training_module,
      user: current_user,
      restaurant: @restaurant,
      status: 'in_progress'
    )

    if @training_session.new_record?
      @training_session.started_at = Time.current
      @training_session.save
    end

    redirect_to restaurant_training_module_training_session_path(@restaurant, @training_module, @training_session)
  end

  # GET /restaurants/:restaurant_id/training_modules/:training_module_id/training_sessions/:id
  def show
    @training_questions = @training_module.training_questions.ordered
    @current_question_index = params[:question_index]&.to_i || 0
    @current_question = @training_questions[@current_question_index]
    
    # Get existing answer if any
    @existing_answer = @training_session.training_answers.find_by(training_question: @current_question) if @current_question
    
    # Calculate progress
    @progress = @training_questions.any? ? ((@current_question_index.to_f / @training_questions.count) * 100).round : 0
    @answered_count = @training_session.training_answers.count
    @total_questions = @training_questions.count
  end

  # PATCH/PUT /restaurants/:restaurant_id/training_modules/:training_module_id/training_sessions/:id
  def update
    # Update session time
    @training_session.update(updated_at: Time.current)
    head :ok
  end

  # POST /restaurants/:restaurant_id/training_modules/:training_module_id/training_sessions/:id/submit
  def submit
    if @training_session.training_answers.count < @training_module.training_questions.count
      redirect_to restaurant_training_module_training_session_path(@restaurant, @training_module, @training_session), 
                  alert: "Please answer all questions before submitting."
      return
    end

    @training_session.submit!
    
    # Create or update completion record if passed
    if @training_session.passed?
      completion = TrainingCompletion.find_or_initialize_by(
        training_module: @training_module,
        user: @training_session.user,
        restaurant: @restaurant
      )
      completion.training_session = @training_session
      completion.completed_at = @training_session.completed_at
      completion.score = @training_session.score
      completion.certified = true
      completion.save
    end

    redirect_to restaurant_training_module_training_session_path(@restaurant, @training_module, @training_session), 
                notice: @training_session.passed? ? "Congratulations! You passed with a score of #{@training_session.score}%." : "You scored #{@training_session.score}%. Please review and try again."
  end

  # POST /restaurants/:restaurant_id/training_modules/:training_module_id/training_sessions/:id/answer
  def answer
    question = @training_module.training_questions.find(params[:question_id])
    selected_option = params[:selected_option]
    
    # Handle multiple select
    if question.multiple_select?
      selected_option = params[:selected_options] || []
      # Convert to array of strings/numbers
      selected_option = selected_option.map(&:to_s) if selected_option.is_a?(Array)
    else
      selected_option = selected_option.to_s if selected_option.present?
    end

    training_answer = @training_session.training_answers.find_or_initialize_by(training_question: question)
    training_answer.selected_option = selected_option
    training_answer.is_correct = question.is_correct?(selected_option)
    training_answer.save

    # Move to next question or show results
    questions_ordered = @training_module.training_questions.ordered.to_a
    current_index = questions_ordered.index(question)
    next_index = current_index ? current_index + 1 : 0
    
    if next_index < questions_ordered.count
      redirect_to restaurant_training_module_training_session_path(@restaurant, @training_module, @training_session, question_index: next_index)
    else
      redirect_to restaurant_training_module_training_session_path(@restaurant, @training_module, @training_session), 
                  notice: "All questions answered. Click 'Submit' to complete the training."
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

  def set_training_session
    @training_session = @training_module.training_sessions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_training_module_path(@restaurant, @training_module), alert: "Training session not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end
end

