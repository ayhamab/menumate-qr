class DietaryFeedback < ApplicationRecord
  belongs_to :menu_item
  belongs_to :restaurant
  belongs_to :user, optional: true

  # Validations
  validates :feedback_type, inclusion: {
    in: %w[incorrect_tag missing_tag allergen_issue description_issue other]
  }
  validates :message, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :severity, inclusion: {
    in: %w[low medium high critical]
  }

  # Serialize reported_tags and suggested_tags as JSON
  serialize :reported_tags, coder: JSON
  serialize :suggested_tags, coder: JSON

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(feedback_type: type) if type.present? }
  scope :by_severity, ->(severity) { where(severity: severity) if severity.present? }
  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :by_menu_item, ->(item) { where(menu_item: item) if item.present? }

  # Instance methods
  def resolved?
    resolved == true
  end

  def unresolved?
    !resolved?
  end

  def critical?
    severity == 'critical'
  end

  def high_severity?
    %w[high critical].include?(severity)
  end

  def resolve!(resolved_by_user = nil, resolution_notes = nil)
    update(
      resolved: true,
      resolved_at: Time.current,
      resolved_by: resolved_by_user,
      resolution_notes: resolution_notes
    )
  end

  def feedback_type_display
    {
      'incorrect_tag' => 'Incorrect Dietary Tag',
      'missing_tag' => 'Missing Dietary Tag',
      'allergen_issue' => 'Allergen Issue',
      'description_issue' => 'Description Issue',
      'other' => 'Other Issue'
    }[feedback_type] || feedback_type.humanize
  end

  def severity_color
    {
      'low' => 'green',
      'medium' => 'yellow',
      'high' => 'orange',
      'critical' => 'red'
    }[severity] || 'gray'
  end

  def reported_tags_display
    return 'None' unless reported_tags.present?
    reported_tags.join(', ')
  end

  def suggested_tags_display
    return 'None' unless suggested_tags.present?
    suggested_tags.join(', ')
  end
end

