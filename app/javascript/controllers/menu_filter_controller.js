import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu-filter"
export default class extends Controller {
  static targets = ["item", "button", "count"]
  static values = { filter: String }

  connect() {
    // Initialize with no filter (show all)
    this.activeFilter = null
    this.updateDisplay()
    
    // Listen for voice command events
    document.addEventListener('voice-filter', this.handleVoiceFilter.bind(this))
    document.addEventListener('voice-clear', this.handleVoiceClear.bind(this))
  }

  disconnect() {
    document.removeEventListener('voice-filter', this.handleVoiceFilter.bind(this))
    document.removeEventListener('voice-clear', this.handleVoiceClear.bind(this))
  }

  filter(event) {
    const filterValue = event.currentTarget.dataset.filter
    const button = event.currentTarget
    
    // Toggle filter - if clicking the same filter, clear it
    if (this.activeFilter === filterValue) {
      this.activeFilter = null
      this.setButtonInactive(button)
    } else {
      // Remove active state from all buttons
      this.buttonTargets.forEach(btn => {
        this.setButtonInactive(btn)
      })
      
      // Add active state to clicked button
      this.activeFilter = filterValue
      this.setButtonActive(button, filterValue)
    }
    
    // Update aria-pressed
    button.setAttribute('aria-pressed', this.activeFilter === filterValue ? 'true' : 'false')
    
    this.updateDisplay()
  }

  setButtonActive(button, filter) {
    // Remove inactive classes
    button.classList.remove("opacity-75")
    
    // Add active state - prominent ring and scale
    button.classList.add("ring-4", "ring-white", "ring-offset-2")
    button.style.transform = 'scale(1.15)'
    button.style.boxShadow = '0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 0 0 4px rgba(255, 255, 255, 0.6), 0 0 20px rgba(251, 191, 36, 0.5)'
    button.style.zIndex = '10'
  }

  setButtonInactive(button) {
    // Remove active classes
    button.classList.remove("ring-4", "ring-white", "ring-offset-2")
    button.style.transform = ''
    button.style.boxShadow = ''
    button.style.zIndex = ''
  }

  updateDisplay() {
    let visibleCount = 0
    
    // Find all menu items in the document (not just within this controller's scope)
    const allMenuItems = document.querySelectorAll('[data-menu-filter-target="item"]')
    
    allMenuItems.forEach(item => {
      const tags = JSON.parse(item.dataset.tags || "[]")
      const shouldShow = this.activeFilter === null || tags.includes(this.activeFilter)
      
      if (shouldShow) {
        item.classList.remove("hidden")
        item.style.display = ''
        visibleCount++
      } else {
        item.classList.add("hidden")
        item.style.display = 'none'
      }
    })
    
    // Update all count targets in the document
    const allCountTargets = document.querySelectorAll('[data-menu-filter-target="count"]')
    allCountTargets.forEach(countTarget => {
      countTarget.textContent = `${visibleCount} ${visibleCount === 1 ? 'item' : 'items'}`
    })
  }

  // Handle voice command events
  handleVoiceFilter(event) {
    const dietaryTag = event.detail.dietaryTag
    this.activeFilter = dietaryTag
    
    // Update button states
    this.buttonTargets.forEach(button => {
      const buttonFilter = button.dataset.filter
      if (buttonFilter === dietaryTag) {
        this.setButtonActive(button, dietaryTag)
        button.setAttribute('aria-pressed', 'true')
      } else {
        this.setButtonInactive(button)
        button.setAttribute('aria-pressed', 'false')
      }
    })
    
    this.updateDisplay()
  }

  handleVoiceClear() {
    this.activeFilter = null
    
    // Reset all buttons
    this.buttonTargets.forEach(button => {
      this.setButtonInactive(button)
      button.setAttribute('aria-pressed', 'false')
    })
    
    this.updateDisplay()
  }
}

