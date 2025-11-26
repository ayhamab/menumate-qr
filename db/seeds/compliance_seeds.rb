# Seed file for dietary laws and regions
# Run with: rails runner db/seeds/compliance_seeds.rb

puts "Creating dietary laws..."

# Halal Law
halal = DietaryLaw.find_or_create_by(code: 'HALAL') do |law|
  law.name = 'Halal Dietary Requirements'
  law.law_type = 'halal'
  law.description = 'Islamic dietary law requiring halal-certified ingredients and prohibiting pork and alcohol'
  law.prohibited_ingredients = ['pork', 'alcohol', 'gelatin (non-halal)', 'lard']
  law.required_certifications = ['halal_certification']
  law.mandatory = true
  law.active = true
end

# Kosher Law
kosher = DietaryLaw.find_or_create_by(code: 'KOSHER') do |law|
  law.name = 'Kosher Dietary Requirements'
  law.law_type = 'kosher'
  law.description = 'Jewish dietary law requiring kosher-certified ingredients and prohibiting pork and shellfish'
  law.prohibited_ingredients = ['pork', 'shellfish', 'mixing meat and dairy']
  law.required_certifications = ['kosher_certification']
  law.mandatory = true
  law.active = true
end

# Allergen Labeling (EU)
allergen_eu = DietaryLaw.find_or_create_by(code: 'ALLERGEN_EU') do |law|
  law.name = 'EU Allergen Labeling Requirements'
  law.law_type = 'allergen_labeling'
  law.description = 'European Union requires clear labeling of 14 major allergens'
  law.requirements = {
    allergens: ['celery', 'gluten', 'crustaceans', 'eggs', 'fish', 'lupin', 'milk', 'molluscs', 'mustard', 'nuts', 'peanuts', 'sesame', 'soybeans', 'sulphites']
  }
  law.mandatory = true
  law.active = true
end

# Nutrition Labeling (US)
nutrition_us = DietaryLaw.find_or_create_by(code: 'NUTRITION_US') do |law|
  law.name = 'US Nutrition Labeling Requirements'
  law.law_type = 'nutrition_labeling'
  law.description = 'United States requires nutrition facts labeling for chain restaurants'
  law.requirements = {
    required_fields: ['calories', 'total_fat', 'saturated_fat', 'trans_fat', 'cholesterol', 'sodium', 'total_carbohydrates', 'dietary_fiber', 'sugars', 'protein']
  }
  law.mandatory = true
  law.active = true
end

# Organic Certification
organic = DietaryLaw.find_or_create_by(code: 'ORGANIC') do |law|
  law.name = 'Organic Certification Requirements'
  law.law_type = 'organic_certification'
  law.description = 'Requirements for organic food labeling and certification'
  law.required_certifications = ['organic_certification']
  law.mandatory = false
  law.active = true
end

puts "Creating regions..."

# United States
us = Region.find_or_create_by(code: 'US') do |region|
  region.name = 'United States'
  region.country_code = 'US'
  region.region_type = 'country'
  region.active = true
end

# European Union
eu = Region.find_or_create_by(code: 'EU') do |region|
  region.name = 'European Union'
  region.country_code = 'EU'
  region.region_type = 'country'
  region.active = true
end

# United Kingdom
uk = Region.find_or_create_by(code: 'GB') do |region|
  region.name = 'United Kingdom'
  region.country_code = 'GB'
  region.region_type = 'country'
  region.active = true
end

# Saudi Arabia
sa = Region.find_or_create_by(code: 'SA') do |region|
  region.name = 'Saudi Arabia'
  region.country_code = 'SA'
  region.region_type = 'country'
  region.active = true
end

# Israel
il = Region.find_or_create_by(code: 'IL') do |region|
  region.name = 'Israel'
  region.country_code = 'IL'
  region.region_type = 'country'
  region.active = true
end

puts "Linking dietary laws to regions..."

# US - Nutrition labeling
RegionDietaryLaw.find_or_create_by(region: us, dietary_law: nutrition_us) do |rdl|
  rdl.enforcement_level = 'mandatory'
  rdl.effective_date = Date.new(2018, 5, 7)
end

# EU - Allergen labeling
RegionDietaryLaw.find_or_create_by(region: eu, dietary_law: allergen_eu) do |rdl|
  rdl.enforcement_level = 'mandatory'
  rdl.effective_date = Date.new(2014, 12, 13)
end

# UK - Allergen labeling (inherits EU rules)
RegionDietaryLaw.find_or_create_by(region: uk, dietary_law: allergen_eu) do |rdl|
  rdl.enforcement_level = 'mandatory'
  rdl.effective_date = Date.new(2014, 12, 13)
end

# Saudi Arabia - Halal
RegionDietaryLaw.find_or_create_by(region: sa, dietary_law: halal) do |rdl|
  rdl.enforcement_level = 'mandatory'
end

# Israel - Kosher (recommended for many establishments)
RegionDietaryLaw.find_or_create_by(region: il, dietary_law: kosher) do |rdl|
  rdl.enforcement_level = 'recommended'
end

puts "Compliance seeds completed!"

