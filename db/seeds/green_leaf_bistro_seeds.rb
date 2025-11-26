# Seed file for Green Leaf Bistro demo restaurant
# Run with: rails runner db/seeds/green_leaf_bistro_seeds.rb

puts "Creating Green Leaf Bistro demo restaurant..."

# Find or create a demo user
user = User.find_or_create_by(email: "demo@greenleafbistro.com") do |u|
  u.password = "demo123456"
  u.password_confirmation = "demo123456"
end

# Find or create the Green Leaf Bistro restaurant
restaurant = Restaurant.find_or_create_by(name: "Green Leaf Bistro") do |r|
  r.user = user
  r.description = "Modern plant-based cuisine with global flavors"
  r.address = "123 Healthy Ave, Food City"
  r.phone_number = "(555) 123-4567"
  r.cuisine = "Plant-Based"
end

# Update restaurant if it already exists but doesn't have a user
if restaurant.user.nil?
  restaurant.update(user: user)
end

puts "Restaurant: #{restaurant.name} (ID: #{restaurant.id})"

# Clear existing menu items for this restaurant
restaurant.menu_items.destroy_all
puts "Cleared existing menu items"

# Disable callbacks to avoid broadcast rendering issues
MenuItem.skip_callback(:commit, :after, :broadcast_create)
MenuItem.skip_callback(:commit, :after, :broadcast_update)

# Helper method to create menu items
def create_menu_item(restaurant, name, description, price, category, dietary_tags = [])
  menu_item = restaurant.menu_items.find_or_initialize_by(name: name)
  menu_item.description = description
  menu_item.price = price
  menu_item.category = category
  menu_item.dietary_tags = dietary_tags
  
  # Save without triggering callbacks to avoid broadcast rendering issues
  if menu_item.new_record?
    menu_item.save(validate: false)
  else
    # Update without callbacks
    menu_item.update_columns(
      description: description,
      price: price,
      category: category,
      dietary_tags: dietary_tags.to_json
    )
  end
  
  puts "  ✓ #{name} (#{category}) - $#{price} #{dietary_tags.any? ? '[ ' + dietary_tags.join(', ') + ' ]' : ''}"
  menu_item
end

puts "\nCreating menu items..."

# ========== APPETIZERS ==========
puts "\n--- Appetizers ---"
create_menu_item(restaurant, "Avocado Toast Trio", 
  "Three varieties: Classic with cherry tomatoes, Mediterranean with olives, and Spicy with jalapeños. Served on artisan sourdough.",
  12.99, "Appetizers", ["vegan", "vegetarian"])

create_menu_item(restaurant, "Crispy Cauliflower Wings", 
  "Buffalo-style cauliflower bites with house-made ranch dipping sauce. Perfectly crispy and flavorful.",
  10.99, "Appetizers", ["vegan", "vegetarian", "gluten-free"])

create_menu_item(restaurant, "Quinoa Stuffed Mushrooms", 
  "Portobello mushrooms filled with herbed quinoa, spinach, and cashew cream. Baked to perfection.",
  11.99, "Appetizers", ["vegan", "vegetarian", "gluten-free", "nut-free"])

create_menu_item(restaurant, "Hummus & Pita Platter", 
  "House-made hummus with roasted red peppers, served with warm pita bread and fresh vegetables.",
  9.99, "Appetizers", ["vegan", "vegetarian"])

# ========== MAIN COURSES ==========
puts "\n--- Main Courses ---"
create_menu_item(restaurant, "Beyond Burger Deluxe", 
  "Plant-based burger with avocado, lettuce, tomato, pickles, and special sauce. Served with sweet potato fries.",
  16.99, "Main Courses", ["vegan", "vegetarian"])

create_menu_item(restaurant, "Mushroom Risotto", 
  "Creamy arborio rice with wild mushrooms, white wine, and fresh herbs. Topped with vegan parmesan.",
  18.99, "Main Courses", ["vegan", "vegetarian", "gluten-free"])

create_menu_item(restaurant, "Thai Green Curry Bowl", 
  "Aromatic green curry with vegetables, tofu, and jasmine rice. Spicy and satisfying.",
  17.99, "Main Courses", ["vegan", "vegetarian", "gluten-free", "nut-free"])

create_menu_item(restaurant, "Mediterranean Buddha Bowl", 
  "Quinoa base with roasted vegetables, chickpeas, olives, and tahini dressing. A complete meal in a bowl.",
  15.99, "Main Courses", ["vegan", "vegetarian", "gluten-free"])

create_menu_item(restaurant, "BBQ Jackfruit Sandwich", 
  "Pulled jackfruit in tangy BBQ sauce, coleslaw, and pickles on a brioche bun. Served with side salad.",
  14.99, "Main Courses", ["vegan", "vegetarian"])

create_menu_item(restaurant, "Zucchini Noodle Pasta", 
  "Spiralized zucchini noodles with marinara sauce, basil, and vegan meatballs. Light and delicious.",
  16.99, "Main Courses", ["vegan", "vegetarian", "gluten-free", "nut-free"])

# ========== DESSERTS ==========
puts "\n--- Desserts ---"
create_menu_item(restaurant, "Chocolate Avocado Mousse", 
  "Rich and creamy chocolate mousse made with avocado. Topped with fresh berries and mint.",
  8.99, "Desserts", ["vegan", "vegetarian", "gluten-free", "nut-free"])

create_menu_item(restaurant, "Vegan Cheesecake", 
  "Creamy cashew-based cheesecake with berry compote. A plant-based classic.",
  9.99, "Desserts", ["vegan", "vegetarian", "gluten-free"])

create_menu_item(restaurant, "Coconut Panna Cotta", 
  "Silky coconut panna cotta with mango coulis. Refreshing and elegant.",
  7.99, "Desserts", ["vegan", "vegetarian", "gluten-free", "nut-free"])

# ========== DRINKS ==========
puts "\n--- Drinks ---"
create_menu_item(restaurant, "Green Detox Smoothie", 
  "Kale, spinach, pineapple, mango, and coconut water. Energizing and nutritious.",
  6.99, "Beverages", ["vegan", "vegetarian", "gluten-free", "nut-free"])

create_menu_item(restaurant, "Turmeric Golden Latte", 
  "Warm turmeric, ginger, and coconut milk latte. Anti-inflammatory and comforting.",
  5.99, "Beverages", ["vegan", "vegetarian", "gluten-free", "nut-free", "dairy-free"])

create_menu_item(restaurant, "Cold Brew Coffee", 
  "Smooth cold brew coffee served over ice. Available with oat, almond, or coconut milk.",
  4.99, "Beverages", ["vegan", "vegetarian", "gluten-free"])

create_menu_item(restaurant, "Fresh Lemonade", 
  "House-made lemonade with fresh lemons and a hint of mint. Refreshing and natural.",
  3.99, "Beverages", ["vegan", "vegetarian", "gluten-free", "nut-free"])

create_menu_item(restaurant, "Kombucha Flight", 
  "Three flavors of house-brewed kombucha: Original, Ginger, and Berry. Probiotic goodness.",
  8.99, "Beverages", ["vegan", "vegetarian", "gluten-free", "nut-free"])

# Re-enable callbacks
MenuItem.set_callback(:commit, :after, :broadcast_create)
MenuItem.set_callback(:commit, :after, :broadcast_update)

puts "\n✓ Green Leaf Bistro menu created successfully!"
puts "\n" + "="*60
puts "RESTAURANT DETAILS"
puts "="*60
puts "Name: #{restaurant.name}"
puts "ID: #{restaurant.id}"
puts "Description: #{restaurant.description}"
puts "Address: #{restaurant.address}"
puts "Phone: #{restaurant.phone_number}"
puts "\n" + "="*60
puts "ACCESS LINKS"
puts "="*60
puts "Public Menu: /restaurants/#{restaurant.id}/menu"
puts "Restaurant Dashboard: /restaurants/#{restaurant.id}"
puts "QR Code PNG: /restaurants/#{restaurant.id}/qr_code_png"
puts "QR Code SVG: /restaurants/#{restaurant.id}/qr_code_svg"
puts "\n" + "="*60
puts "LOGIN CREDENTIALS"
puts "="*60
puts "Email: demo@greenleafbistro.com"
puts "Password: demo123456"
puts "\n" + "="*60
puts "MENU SUMMARY"
puts "="*60
puts "Total Items: #{restaurant.menu_items.count}"
puts "Appetizers: #{restaurant.menu_items.where(category: 'Appetizers').count}"
puts "Main Courses: #{restaurant.menu_items.where(category: 'Main Courses').count}"
puts "Desserts: #{restaurant.menu_items.where(category: 'Desserts').count}"
puts "Beverages: #{restaurant.menu_items.where(category: 'Beverages').count}"
puts "\nVegan Items: #{restaurant.menu_items.where("dietary_tags LIKE ?", '%"vegan"%').count}"
puts "Gluten-Free Items: #{restaurant.menu_items.where("dietary_tags LIKE ?", '%"gluten-free"%').count}"
puts "Nut-Free Items: #{restaurant.menu_items.where("dietary_tags LIKE ?", '%"nut-free"%').count}"
puts "="*60

