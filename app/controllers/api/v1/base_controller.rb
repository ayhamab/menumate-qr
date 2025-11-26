class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key
  before_action :check_rate_limit

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  protected

  def authenticate_api_key
    api_key = request.headers['X-API-Key'] || params[:api_key]
    
    unless api_key.present?
      render json: { 
        error: 'API key required',
        message: 'Please provide your API key in the X-API-Key header or as a query parameter'
      }, status: :unauthorized
      return
    end

    @api_key = ApiKey.active.find_by(token: api_key)
    
    unless @api_key
      render json: { 
        error: 'Invalid API key',
        message: 'The provided API key is invalid or has expired'
      }, status: :unauthorized
      return
    end

    @current_user = @api_key.user
    @api_key.record_usage
  end

  def check_rate_limit
    # Basic rate limiting: 1000 requests per hour per API key
    cache_key = "api_rate_limit:#{@api_key.id}:#{Time.current.hour}"
    count = Rails.cache.fetch(cache_key, expires_in: 1.hour) { 0 }
    
    if count >= 1000
      render json: { 
        error: 'Rate limit exceeded',
        message: 'You have exceeded the rate limit of 1000 requests per hour. Please try again later.'
      }, status: :too_many_requests
      return
    end

    Rails.cache.write(cache_key, count + 1, expires_in: 1.hour)
  end

  def current_user
    @current_user
  end

  def not_found(exception)
    render json: { 
      error: 'Not found',
      message: exception.message
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { 
      error: 'Validation failed',
      message: exception.record.errors.full_messages.join(', ')
    }, status: :unprocessable_entity
  end

  def bad_request(exception)
    render json: { 
      error: 'Bad request',
      message: exception.message
    }, status: :bad_request
  end
end
