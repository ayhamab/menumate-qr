module ApplicationHelper
  # Social sharing URLs
  def facebook_share_url(url, text = "")
    "https://www.facebook.com/sharer/sharer.php?u=#{CGI.escape(url)}"
  end

  def twitter_share_url(url, text = "")
    "https://twitter.com/intent/tweet?url=#{CGI.escape(url)}&text=#{CGI.escape(text)}"
  end

  def whatsapp_share_url(url, text = "")
    "https://wa.me/?text=#{CGI.escape("#{text} #{url}")}"
  end

  def linkedin_share_url(url, text = "")
    "https://www.linkedin.com/sharing/share-offsite/?url=#{CGI.escape(url)}"
  end

  def email_share_url(url, subject = "", body = "")
    "mailto:?subject=#{CGI.escape(subject)}&body=#{CGI.escape(body)}"
  end

  def sms_share_url(url, text = "")
    "sms:?body=#{CGI.escape("#{text} #{url}")}"
  end

  # Branding helpers
  def restaurant_branding(restaurant)
    restaurant&.branding_or_default || Branding.new
  end

  def branding_css_variables(restaurant)
    branding = restaurant_branding(restaurant)
    branding.css_variables.map { |key, value| "#{key}: #{value}" }.join('; ')
  end

  def branding_logo(restaurant, size: 'auto')
    branding = restaurant_branding(restaurant)
    if branding.logo.attached?
      image_tag branding.logo, style: "max-width: #{size}; max-height: #{size};", alt: branding.display_name
    else
      content_tag :div, class: "bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-bold text-xl px-4 py-2 rounded-lg" do
        branding.display_name.first(2).upcase
      end
    end
  end

  def branding_favicon(restaurant)
    branding = restaurant_branding(restaurant)
    if branding.favicon.attached?
      favicon_link_tag branding.favicon
    else
      favicon_link_tag 'data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🍽️</text></svg>'
    end
  end

  def show_menumate_branding?(restaurant)
    branding = restaurant_branding(restaurant)
    !branding.hide_menumate_branding
  end

  # Check if the current user owns the restaurant
  def restaurant_owner?(restaurant)
    return false unless restaurant.user.present?
    
    begin
      return false unless respond_to?(:user_signed_in?) && user_signed_in?
      return false unless respond_to?(:current_user)
      restaurant.user == current_user
    rescue NoMethodError, NameError
      false
    end
  end

  # Check if current user is a team member
  def restaurant_team_member?(restaurant)
    return false unless respond_to?(:user_signed_in?) && user_signed_in? && respond_to?(:current_user)
    return true if restaurant.user == current_user
    
    begin
      restaurant.restaurant_teams.active.exists?(user: current_user)
    rescue
      false
    end
  end

  # Get current user's team role for restaurant
  def restaurant_team_role(restaurant)
    return 'owner' if restaurant_owner?(restaurant)
    return nil unless respond_to?(:user_signed_in?) && user_signed_in? && respond_to?(:current_user)
    
    begin
      team_member = restaurant.restaurant_teams.active.find_by(user: current_user)
      team_member&.role
    rescue
      nil
    end
  end

  # Check if user can manage team
  def can_manage_team?(restaurant)
    return true if restaurant_owner?(restaurant)
    return false unless restaurant_team_member?(restaurant)
    
    role = restaurant_team_role(restaurant)
    role == 'manager' || role == 'chef'
  end

  # Check if user can edit menu items
  def can_edit_menu_items?(restaurant)
    return true if restaurant_owner?(restaurant)
    return false unless restaurant_team_member?(restaurant)
    
    role = restaurant_team_role(restaurant)
    ['chef', 'manager'].include?(role)
  end

  # Generate QR code as SVG for a given URL
  def qr_code_svg(url, size: 200)
    require 'rqrcode'
    
    qr = RQRCode::QRCode.new(url)
    qr.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true,
      svg_attributes: {
        width: size,
        height: size
      }
    ).html_safe
  end
end
