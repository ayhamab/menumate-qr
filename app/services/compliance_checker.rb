class ComplianceChecker
  attr_reader :restaurant, :region, :menu_item

  def initialize(restaurant: nil, region: nil, menu_item: nil)
    @restaurant = restaurant
    @region = region
    @menu_item = menu_item
  end

  # Check compliance for a single menu item in a region
  def check_menu_item(menu_item, region)
    return { compliant: true, violations: [] } unless region.present?
    
    region_laws = region.mandatory_laws
    return { compliant: true, violations: [] } if region_laws.empty?
    
    all_violations = []
    compliance_results = {}
    
    region_laws.each do |law|
      result = law.check_compliance(menu_item)
      compliance_results[law.code] = result
      
      unless result[:compliant]
        all_violations.concat(result[:violations])
        
        # Create or update compliance record
        compliance = MenuItemCompliance.find_or_initialize_by(
          menu_item: menu_item,
          dietary_law: law,
          region: region
        )
        compliance.status = 'non_compliant'
        compliance.violations = result[:violations]
        compliance.last_checked_at = Time.current
        compliance.checked_by = 'system'
        compliance.save
      else
        # Mark as compliant
        compliance = MenuItemCompliance.find_or_initialize_by(
          menu_item: menu_item,
          dietary_law: law,
          region: region
        )
        compliance.status = 'compliant'
        compliance.violations = []
        compliance.last_checked_at = Time.current
        compliance.checked_by = 'system'
        compliance.save
      end
    end
    
    {
      compliant: all_violations.empty?,
      violations: all_violations,
      results: compliance_results,
      region: region
    }
  end

  # Check all menu items for a restaurant in a region
  def check_restaurant(restaurant, region)
    return { compliant: true, items: [], violations: [] } unless restaurant && region
    
    menu_items = restaurant.menu_items
    results = []
    all_violations = []
    
    menu_items.each do |item|
      item_result = check_menu_item(item, region)
      results << {
        menu_item: item,
        compliance: item_result
      }
      all_violations.concat(item_result[:violations]) unless item_result[:compliant]
    end
    
    compliant_count = results.count { |r| r[:compliance][:compliant] }
    total_count = results.count
    
    {
      compliant: all_violations.empty?,
      compliance_percentage: total_count > 0 ? ((compliant_count.to_f / total_count) * 100).round(2) : 100,
      compliant_items: compliant_count,
      total_items: total_count,
      violations: all_violations,
      items: results
    }
  end

  # Generate compliance report
  def generate_report(restaurant, region = nil)
    if region.present?
      # Regional compliance report
      result = check_restaurant(restaurant, region)
      
      ComplianceReport.create(
        restaurant: restaurant,
        region: region,
        report_type: 'regional_compliance',
        title: "Compliance Report: #{restaurant.name} - #{region.name}",
        summary: "Compliance check for #{restaurant.name} in #{region.name}",
        findings: result[:violations].map { |v| { type: v[:type], message: v[:message] } },
        violations_summary: summarize_violations(result[:violations]),
        compliance_percentage: result[:compliance_percentage]
      )
    else
      # Full compliance report across all regions
      regions = restaurant.regions.active
      all_results = []
      
      regions.each do |reg|
        result = check_restaurant(restaurant, reg)
        all_results << {
          region: reg,
          result: result
        }
      end
      
      total_violations = all_results.flat_map { |r| r[:result][:violations] }
      avg_compliance = all_results.any? ? 
        (all_results.sum { |r| r[:result][:compliance_percentage] } / all_results.count).round(2) : 100
      
      ComplianceReport.create(
        restaurant: restaurant,
        report_type: 'full_compliance',
        title: "Full Compliance Report: #{restaurant.name}",
        summary: "Comprehensive compliance check for #{restaurant.name} across all regions",
        findings: total_violations.map { |v| { type: v[:type], message: v[:message] } },
        violations_summary: summarize_violations(total_violations),
        compliance_percentage: avg_compliance
      )
    end
  end

  private

  def summarize_violations(violations)
    return [] if violations.empty?
    
    violations.group_by { |v| v[:type] }.map do |type, items|
      {
        type: type,
        count: items.count,
        examples: items.first(3).map { |i| i[:message] }
      }
    end
  end
end

