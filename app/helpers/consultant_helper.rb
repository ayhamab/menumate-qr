module ConsultantHelper
  # Check if current user is a consultant
  def consultant_signed_in?
    respond_to?(:current_consultant) && current_consultant.present?
  end

  # Check if consultant can access restaurant
  def consultant_can_access?(restaurant, permission_type = 'view')
    return false unless consultant_signed_in?
    current_consultant.can_access_restaurant?(restaurant) &&
      current_consultant.has_permission?(restaurant, permission_type)
  end

  # Get consultant for restaurant (if any)
  def restaurant_consultant(restaurant)
    restaurant.consultants.active.first
  end

  # Check if restaurant has consultant
  def has_consultant?(restaurant)
    restaurant.consultants.active.any?
  end
end

