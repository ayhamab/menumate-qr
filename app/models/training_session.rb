class TrainingSession < ApplicationRecord
  belongs_to :training_module
  belongs_to :user
  belongs_to :restaurant, optional: true
  has_many :training_answers, dependent: :destroy

  # Status: in_progress, completed, passed, failed
  validates :status, inclusion: { in: %w[in_progress completed passed failed] }
  validates :score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Scopes
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: ['completed', 'passed', 'failed']) }
  scope :passed, -> { where(status: 'passed') }
  scope :failed, -> { where(status: 'failed') }
  scope :by_user, ->(user) { where(user: user) if user.present? }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :recent, -> { order(updated_at: :desc) }

  # Instance methods
  def in_progress?
    status == 'in_progress'
  end

  def completed?
    ['completed', 'passed', 'failed'].include?(status)
  end

  def passed?
    status == 'passed'
  end

  def failed?
    status == 'failed'
  end

  def calculate_score
    return nil if training_answers.empty?
    
    correct_answers = training_answers.joins(:training_question)
                                      .where('training_answers.selected_option = training_questions.correct_option')
                                      .count
    
    total_questions = training_module.training_questions.count
    return 0 if total_questions.zero?
    
    ((correct_answers.to_f / total_questions) * 100).round(2)
  end

  def submit!
    calculated_score = calculate_score
    update(
      score: calculated_score,
      completed_at: Time.current,
      status: calculated_score && calculated_score >= training_module.passing_score ? 'passed' : 'failed'
    )
  end

  def time_spent_minutes
    return 0 unless started_at.present?
    end_time = completed_at || updated_at
    ((end_time - started_at) / 60).round
  end
end

