// Track menu item clicks for analytics
function trackMenuItemClick(menuItemId, restaurantId) {
  // Send async request to track click
  fetch(`/restaurants/${restaurantId}/menu_items/${menuItemId}/track_click`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
      'X-Requested-With': 'XMLHttpRequest'
    },
    credentials: 'same-origin'
  }).catch(error => {
    console.log('Analytics tracking error:', error);
  });
}

// Track menu item orders
function trackMenuItemOrder(menuItemId, restaurantId, revenue = null) {
  fetch(`/restaurants/${restaurantId}/menu_items/${menuItemId}/track_order`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
      'X-Requested-With': 'XMLHttpRequest'
    },
    credentials: 'same-origin',
    body: JSON.stringify({ revenue: revenue })
  }).catch(error => {
    console.log('Order tracking error:', error);
  });
}

