class DietaryLaw < ApplicationRecord
  has_many :region_dietary_laws, dependent: :destroy
  has_many :regions, through: :region_dietary_laws
  has_many :menu_item_compliances, dependent: :destroy

  # Law types: halal, kosher, vegetarian_mandate, allergen_labeling, nutrition_labeling, organic_certification, gmo_labeling, alcohol_restrictions
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :law_type, inclusion: {
    in: %w[halal kosher vegetarian_mandate allergen_labeling nutrition_labeling organic_certification gmo_labeling alcohol_restrictions other]
  }
  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }

  # Serialize requirements as JSON
  serialize :requirements, coder: JSON
  serialize :prohibited_ingredients, coder: JSON
  serialize :required_certifications, coder: JSON

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(law_type: type) if type.present? }
  scope :mandatory, -> { where(mandatory: true) }
  scope :ordered, -> { order(:name) }

  # Instance methods
  def active?
    active == true
  end

  def mandatory?
    mandatory == true
  end

  def halal?
    law_type == 'halal'
  end

  def kosher?
    law_type == 'kosher'
  end

  def requires_certification?
    required_certifications.present? && required_certifications.any?
  end

  def prohibits_ingredient?(ingredient_name)
    return false unless prohibited_ingredients.present?
    prohibited_ingredients.any? { |prohibited| ingredient_name.downcase.include?(prohibited.downcase) }
  end

  def check_compliance(menu_item)
    violations = []
    
    # Check prohibited ingredients
    if prohibited_ingredients.present?
      menu_item.ingredients.each do |ingredient|
        if prohibits_ingredient?(ingredient.name)
          violations << {
            type: 'prohibited_ingredient',
            ingredient: ingredient.name,
            message: "#{ingredient.name} is prohibited by #{name}"
          }
        end
      end
    end
    
    # Check required certifications
    if requires_certification?
      required_certifications.each do |cert|
        unless menu_item.certifications&.include?(cert)
          violations << {
            type: 'missing_certification',
            certification: cert,
            message: "#{name} requires #{cert} certification"
          }
        end
      end
    end
    
    # Check dietary tags compliance
    case law_type
    when 'halal'
      if menu_item.dietary_tags&.include?('pork') || menu_item.dietary_tags&.include?('alcohol')
        violations << {
          type: 'dietary_violation',
          message: "Halal compliance requires no pork or alcohol"
        }
      end
    when 'kosher'
      if menu_item.dietary_tags&.include?('pork') || menu_item.dietary_tags&.include?('shellfish')
        violations << {
          type: 'dietary_violation',
          message: "Kosher compliance requires no pork or shellfish"
        }
      end
    end
    
    {
      compliant: violations.empty?,
      violations: violations,
      law: self
    }
  end
end

