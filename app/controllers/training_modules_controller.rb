class TrainingModulesController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :require_edit_permission, except: [:index, :show]
  before_action :set_training_module, only: [:show, :edit, :update, :destroy]

  # GET /restaurants/:restaurant_id/training_modules
  def index
    @training_modules = @restaurant.training_modules.includes(:training_questions, :training_completions).ordered
    @training_modules = @training_modules.where(module_type: params[:type]) if params[:type].present?
    @training_modules = @training_modules.where(active: params[:active] == 'true') if params[:active].present?
    
    # Get user's completion status if logged in
    if respond_to?(:current_user) && current_user
      @user_completions = TrainingCompletion.where(
        user: current_user,
        restaurant: @restaurant
      ).includes(:training_session).index_by(&:training_module_id)
    end
  end

  # GET /restaurants/:restaurant_id/training_modules/:id
  def show
    @training_questions = @training_module.training_questions.ordered
    @training_session = nil
    
    # Get or create training session for current user
    if respond_to?(:current_user) && current_user
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
    end
  end

  # GET /restaurants/:restaurant_id/training_modules/new
  def new
    @training_module = @restaurant.training_modules.build(
      passing_score: 80,
      active: true,
      required: false
    )
  end

  # POST /restaurants/:restaurant_id/training_modules
  def create
    @training_module = @restaurant.training_modules.build(training_module_params)

    if @training_module.save
      redirect_to restaurant_training_module_path(@restaurant, @training_module), notice: "Training module created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/training_modules/:id/edit
  def edit
  end

  # PATCH/PUT /restaurants/:restaurant_id/training_modules/:id
  def update
    if @training_module.update(training_module_params)
      redirect_to restaurant_training_module_path(@restaurant, @training_module), notice: "Training module updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/training_modules/:id
  def destroy
    if @training_module.destroy
      redirect_to restaurant_training_modules_path(@restaurant), notice: "Training module deleted."
    else
      redirect_to restaurant_training_module_path(@restaurant, @training_module), alert: "Could not delete training module."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_training_module
    @training_module = @restaurant.training_modules.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_training_modules_path(@restaurant), alert: "Training module not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_training_modules_path(@restaurant), alert: "You don't have permission to manage training modules."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def training_module_params
    params.require(:training_module).permit(:title, :description, :content, :module_type, :position, :passing_score, :certification_valid_days, :active, :required, :learning_objectives, :notes)
  end
end

