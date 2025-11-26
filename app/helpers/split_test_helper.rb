module SplitTestHelper
  # Get the variant to show for a user/session
  def get_variant_for_test(split_test, session_id = nil)
    return nil unless split_test&.active?
    
    # Generate or use provided session ID
    session_id ||= session.id || SecureRandom.hex(16)
    
    # Check if user already has a variant assigned (sticky assignment)
    session_key = "split_test_#{split_test.id}_variant"
    cached_variant_id = session[session_key]
    
    if cached_variant_id.present?
      variant = split_test.split_test_variants.find_by(id: cached_variant_id)
      return variant if variant.present?
    end
    
    # Assign variant based on weight
    variant = assign_variant_by_weight(split_test)
    
    # Cache assignment in session
    session[session_key] = variant.id if variant
    
    variant
  end

  # Track impression for a variant
  def track_impression(split_test, variant, request = nil)
    return unless split_test&.active? && variant
    
    session_id = session.id || SecureRandom.hex(16)
    SplitTestResult.track_impression(split_test, variant, session_id, request)
  end

  # Track click for a variant
  def track_click(split_test, variant, request = nil)
    return unless split_test&.active? && variant
    
    session_id = session.id || SecureRandom.hex(16)
    SplitTestResult.track_click(split_test, variant, session_id, request)
  end

  private

  # Assign variant based on weight (weighted random)
  def assign_variant_by_weight(split_test)
    variants = split_test.split_test_variants.active.to_a
    return nil if variants.empty?
    
    # Calculate total weight
    total_weight = variants.sum(&:weight)
    return variants.first if total_weight.zero?
    
    # Generate random number
    random = rand(total_weight)
    
    # Find variant based on cumulative weight
    cumulative = 0
    variants.each do |variant|
      cumulative += variant.weight
      return variant if random < cumulative
    end
    
    # Fallback to first variant
    variants.first
  end
end

