class ApiKeysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_api_key, only: [:destroy, :regenerate]

  # GET /api_keys
  def index
    @api_keys = current_user.api_keys.order(created_at: :desc)
  end

  # POST /api_keys
  def create
    @api_key = current_user.api_keys.build(api_key_params)
    
    if @api_key.save
      redirect_to api_keys_path, notice: "API key created successfully. Make sure to copy it now - you won't be able to see it again!"
    else
      @api_keys = current_user.api_keys.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /api_keys/:id
  def destroy
    @api_key.destroy
    redirect_to api_keys_path, notice: "API key deleted successfully."
  end

  # POST /api_keys/:id/regenerate
  def regenerate
    @api_key.update(token: ApiKey.generate_unique_token, last_used_at: nil, usage_count: 0)
    redirect_to api_keys_path, notice: "API key regenerated successfully. Make sure to copy the new key!"
  end

  private

  def set_api_key
    @api_key = current_user.api_keys.find(params[:id])
  end

  def api_key_params
    params.require(:api_key).permit(:name, :expires_at)
  end
end
