class MenuUpdatesChannel < ApplicationCable::Channel
  def subscribed
    restaurant_id = params[:restaurant_id]
    stream_from "menu_updates_restaurant_#{restaurant_id}" if restaurant_id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
