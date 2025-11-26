class PredictionModel < ApplicationRecord
  has_many :menu_predictions, dependent: :destroy

  # Model types: linear_regression, random_forest, neural_network, gradient_boosting
  validates :model_type, inclusion: {
    in: %w[linear_regression random_forest neural_network gradient_boosting ensemble]
  }
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :version, presence: true

  # Serialize model parameters and metrics as JSON
  serialize :model_parameters, coder: JSON
  serialize :training_metrics, coder: JSON
  serialize :feature_importance, coder: JSON

  # Scopes
  scope :active, -> { where(active: true) }
  scope :latest, -> { order(version: :desc) }
  scope :by_type, ->(type) { where(model_type: type) if type.present? }

  # Instance methods
  def active?
    active == true
  end

  def latest_version?
    PredictionModel.where(name: name).maximum(:version) == version
  end

  def accuracy_display
    return "N/A" unless training_metrics.present? && training_metrics['accuracy'].present?
    "#{(training_metrics['accuracy'] * 100).round(2)}%"
  end

  def r2_score_display
    return "N/A" unless training_metrics.present? && training_metrics['r2_score'].present?
    training_metrics['r2_score'].round(3)
  end

  def top_features(limit = 5)
    return [] unless feature_importance.present?
    feature_importance.sort_by { |_, importance| -importance }
                      .first(limit)
                      .map { |feature, _| feature }
  end
end

