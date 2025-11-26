class AddTranslationsToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_column :menu_items, :name_translations, :text
    add_column :menu_items, :description_translations, :text
  end
end

