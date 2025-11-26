class TrainingQuestion < ApplicationRecord
  belongs_to :training_module
  has_many :training_answers, dependent: :destroy

  # Question types: multiple_choice, true_false, multiple_select
  validates :question_text, presence: true
  validates :question_type, inclusion: { in: %w[multiple_choice true_false multiple_select] }
  validates :correct_option, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  # Serialize options as JSON
  serialize :options, coder: JSON
  serialize :correct_option, coder: JSON

  # Scopes
  scope :ordered, -> { order(:position, :created_at) }

  # Instance methods
  def multiple_choice?
    question_type == 'multiple_choice'
  end

  def true_false?
    question_type == 'true_false'
  end

  def multiple_select?
    question_type == 'multiple_select'
  end

  def is_correct?(selected_option)
    if multiple_select?
      # For multiple select, correct_option is an array
      correct_array = correct_option.is_a?(Array) ? correct_option : [correct_option]
      selected_array = selected_option.is_a?(Array) ? selected_option : [selected_option]
      correct_array.sort == selected_array.sort
    else
      correct_option.to_s == selected_option.to_s
    end
  end

  def explanation_display
    explanation.presence || "The correct answer is: #{options[correct_option.to_i] if options.present? && correct_option.present?}"
  end
end

