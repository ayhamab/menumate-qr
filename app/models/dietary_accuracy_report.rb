class DietaryAccuracyReport < ApplicationRecord
  belongs_to :menu_item

  # Validations
  validates :issue_type, presence: true, inclusion: { 
    in: %w[missing_allergen incorrect_allergen missing_dietary_tag incorrect_dietary_tag],
    message: "must be a valid issue type"
  }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }

  # Scopes
  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_issue_type, ->(type) { where(issue_type: type) }

  # Class methods
  def self.issue_types
    {
      'missing_allergen' => 'Missing Allergen',
      'incorrect_allergen' => 'Incorrect Allergen Listed',
      'missing_dietary_tag' => 'Missing Dietary Tag',
      'incorrect_dietary_tag' => 'Incorrect Dietary Tag'
    }
  end

  def issue_type_display
    self.class.issue_types[issue_type] || issue_type.humanize
  end
end
