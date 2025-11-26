class DiscoveriesController < ApplicationController
  # Public action - no authentication required
  def index
    @query = params[:query]&.strip
    @cuisine = params[:cuisine]&.strip
    @dietary_option = params[:dietary_option]&.strip
    
    @restaurants = Restaurant.all
    
    # Apply search filters
    @restaurants = @restaurants.by_name(@query) if @query.present?
    @restaurants = @restaurants.by_cuisine(@cuisine) if @cuisine.present?
    @restaurants = @restaurants.with_dietary_option(@dietary_option) if @dietary_option.present?
    
    # Order by name
    @restaurants = @restaurants.order(:name)
    
    # Get unique cuisines for filter dropdown
    @cuisines = Restaurant.where.not(cuisine: [nil, '']).distinct.pluck(:cuisine).compact.sort
    
    # Get unique dietary options from menu items
    @dietary_options = MenuItem.where.not(dietary_tags: [nil, ''])
                                .pluck(:dietary_tags)
                                .map do |tags|
                                  if tags.is_a?(String)
                                    begin
                                      JSON.parse(tags)
                                    rescue
                                      []
                                    end
                                  else
                                    tags || []
                                  end
                                end
                                .flatten
                                .compact
                                .uniq
                                .sort
  end
end

