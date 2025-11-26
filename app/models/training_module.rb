class TrainingModule < ApplicationRecord
  belongs_to :restaurant, optional: true
  has_many :training_sessions, dependent: :destroy
  has_many :training_questions, dependent: :destroy
  has_many :training_completions, dependent: :destroy

  # Module types: dietary_requirements, allergy_safety, food_handling, customer_service
  validates :title, presence: true, length: { maximum: 255 }
  validates :module_type, inclusion: { in: %w[dietary_requirements allergy_safety food_handling customer_service general] }
  validates :passing_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(module_type: type) if type.present? }
  scope :required, -> { where(required: true) }
  scope :ordered, -> { order(:position, :created_at) }

  # Instance methods
  def active?
    active == true
  end

  def required?
    required == true
  end

  def completion_rate(restaurant = nil)
    scope = training_completions.passed
    scope = scope.where(restaurant: restaurant) if restaurant.present?
    total_attempts = training_sessions.count
    return 0 if total_attempts.zero?
    ((scope.count.to_f / total_attempts) * 100).round(2)
  end

  def average_score(restaurant = nil)
    scope = training_sessions
    scope = scope.joins(:user).where(users: { id: restaurant&.team_members&.pluck(:id) }) if restaurant.present?
    scores = scope.pluck(:score).compact
    return 0 if scores.empty?
    (scores.sum.to_f / scores.count).round(2)
  end

  def estimated_duration
    # Estimate based on content length and number of questions
    base_time = 5 # 5 minutes base
    content_time = (content&.length || 0) / 100 # 1 minute per 100 characters
    question_time = training_questions.count * 2 # 2 minutes per question
    (base_time + content_time + question_time).round
  end
end

