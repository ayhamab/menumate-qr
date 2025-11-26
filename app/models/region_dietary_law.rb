class RegionDietaryLaw < ApplicationRecord
  belongs_to :region
  belongs_to :dietary_law

  validates :region_id, uniqueness: {
    scope: :dietary_law_id,
    message: "already has this dietary law"
  }
  validates :enforcement_level, inclusion: {
    in: %w[mandatory recommended optional]
  }

  # Scopes
  scope :mandatory, -> { where(enforcement_level: 'mandatory') }
  scope :recommended, -> { where(enforcement_level: 'recommended') }
  scope :optional, -> { where(enforcement_level: 'optional') }

  # Instance methods
  def mandatory?
    enforcement_level == 'mandatory'
  end

  def recommended?
    enforcement_level == 'recommended'
  end

  def optional?
    enforcement_level == 'optional'
  end
end

