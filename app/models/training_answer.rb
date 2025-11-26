class TrainingAnswer < ApplicationRecord
  belongs_to :training_session
  belongs_to :training_question

  validates :selected_option, presence: true

  # Serialize selected_option as JSON (for multiple select questions)
  serialize :selected_option, coder: JSON

  # Instance methods
  def correct?
    training_question.is_correct?(selected_option)
  end

  def selected_option_display
    if selected_option.is_a?(Array)
      selected_option.join(', ')
    else
      selected_option.to_s
    end
  end
end

