class MenuItemPromotion < ApplicationRecord
  belongs_to :menu_item
  belongs_to :promotion
end

