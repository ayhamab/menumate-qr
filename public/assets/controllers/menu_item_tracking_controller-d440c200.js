import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    menuItemId: Number,
    restaurantId: Number
  }

  connect() {
    // Track view when item is displayed
    this.trackView()
  }

  click() {
    // Track click when item is clicked
    this.trackClick()
  }

  trackView() {
    // Views are tracked server-side when menu loads
    // This is just for client-side tracking if needed
  }

  trackClick() {
    const menuItemId = this.menuItemIdValue
    const restaurantId = this.restaurantIdValue
    
    fetch(`/restaurants/${restaurantId}/menu_items/${menuItemId}/track_click`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    }).catch(error => {
      console.log('Click tracking error:', error)
    })
  }
}

