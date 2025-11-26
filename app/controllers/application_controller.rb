class ApplicationController < ActionController::Base
  include SplitTestHelper
  include LocationHelper
  
  # Devise helper for suppliers
  def current_supplier
    @current_supplier ||= Supplier.find_by(id: session[:supplier_id]) if session[:supplier_id]
  end
  helper_method :current_supplier
  
  def authenticate_supplier!
    redirect_to new_supplier_session_path unless current_supplier
  end
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Configure Devise permitted parameters if Devise is available
  before_action :configure_permitted_parameters, if: -> { respond_to?(:devise_controller?) && devise_controller? }

  protected

  def configure_permitted_parameters
    return unless respond_to?(:devise_parameter_sanitizer)
    
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end
  
  # Devise will provide current_consultant and consultant_signed_in? automatically
  # Devise will provide current_supplier and supplier_signed_in? automatically
  # No need to override unless we need custom logic
end
