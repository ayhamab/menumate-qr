class Api::V1::QrCodesController < Api::V1::BaseController
  before_action :set_restaurant

  # GET /api/v1/restaurants/:restaurant_id/qr_codes
  def index
    qr_codes = @restaurant.qr_codes
    
    render json: {
      data: qr_codes.map { |qr| qr_code_to_json(qr) },
      meta: {
        total: qr_codes.count,
        restaurant_id: @restaurant.id
      }
    }
  end

  # POST /api/v1/restaurants/:restaurant_id/qr_codes
  def create
    qr_code = @restaurant.qr_codes.build(qr_code_params)
    
    if qr_code.save
      render json: {
        data: qr_code_to_json(qr_code)
      }, status: :created
    else
      render json: {
        error: 'Validation failed',
        message: qr_code.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/restaurants/:restaurant_id/qr_codes/generate
  def generate
    # Generate QR code if doesn't exist
    qr_code = @restaurant.qr_codes.first_or_create!(token: SecureRandom.hex(16))
    
    menu_url = menu_restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol)
    
    render json: {
      data: {
        qr_code: qr_code_to_json(qr_code),
        menu_url: menu_url,
        qr_code_url: qr_code_png_restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol),
        qr_code_svg_url: qr_code_svg_restaurant_url(@restaurant, host: request.host_with_port, protocol: request.protocol)
      }
    }
  end

  # GET /api/v1/restaurants/:restaurant_id/qr_codes/stats
  def stats
    qr_scans = @restaurant.qr_scans
    
    render json: {
      data: {
        total_scans: qr_scans.count,
        scans_today: qr_scans.where('scanned_at >= ?', Date.today).count,
        scans_this_week: qr_scans.where('scanned_at >= ?', 1.week.ago).count,
        scans_this_month: qr_scans.where('scanned_at >= ?', 1.month.ago).count,
        recent_scans: qr_scans.order(scanned_at: :desc).limit(10).map { |scan|
          {
            scanned_at: scan.scanned_at.iso8601,
            ip_address: scan.ip_address,
            user_agent: scan.user_agent
          }
        }
      }
    }
  end

  private

  def set_restaurant
    @restaurant = current_user.restaurants.find(params[:restaurant_id])
  end

  def qr_code_params
    params.require(:qr_code).permit(:token)
  end

  def qr_code_to_json(qr_code)
    {
      id: qr_code.id,
      token: qr_code.token,
      restaurant_id: qr_code.restaurant_id,
      created_at: qr_code.created_at.iso8601,
      updated_at: qr_code.updated_at.iso8601
    }
  end
end
