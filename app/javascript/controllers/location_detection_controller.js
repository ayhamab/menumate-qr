import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    restaurantId: Number,
    menuUrl: String
  }

  connect() {
    this.locationDetected = false
    this.checkLocationPermission()
  }

  checkLocationPermission() {
    if (!navigator.geolocation) {
      this.updateStatus("Geolocation is not supported by your browser.", "error")
      return
    }

    // Check if location is already in session
    const savedLocation = sessionStorage.getItem(`location_${this.restaurantIdValue}`)
    if (savedLocation) {
      this.locationDetected = true
      return
    }
  }

  requestLocation() {
    if (!navigator.geolocation) {
      this.updateStatus("Geolocation is not supported by your browser.", "error")
      return
    }

    this.updateStatus("Requesting location permission...", "info")
    
    navigator.geolocation.getCurrentPosition(
      (position) => this.handleLocationSuccess(position),
      (error) => this.handleLocationError(error),
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 300000 // 5 minutes
      }
    )
  }

  handleLocationSuccess(position) {
    const latitude = position.coords.latitude
    const longitude = position.coords.longitude
    
    // Save to session storage
    sessionStorage.setItem(`location_${this.restaurantIdValue}`, JSON.stringify({
      latitude,
      longitude,
      timestamp: Date.now()
    }))
    
    this.locationDetected = true
    this.updateStatus("Location detected! Loading menu for your area...", "success")
    
    // Redirect to menu with GPS coordinates
    const menuUrl = this.menuUrlValue || `/restaurants/${this.restaurantIdValue}/menu`
    const separator = menuUrl.includes('?') ? '&' : '?'
    window.location.href = `${menuUrl}${separator}latitude=${latitude}&longitude=${longitude}`
  }

  handleLocationError(error) {
    let message = "Unable to detect your location. "
    
    switch(error.code) {
      case error.PERMISSION_DENIED:
        message += "Please allow location access to see location-specific menu items."
        break
      case error.POSITION_UNAVAILABLE:
        message += "Location information is unavailable."
        break
      case error.TIMEOUT:
        message += "Location request timed out."
        break
      default:
        message += "An unknown error occurred."
        break
    }
    
    this.updateStatus(message, "error")
  }

  clearLocation() {
    sessionStorage.removeItem(`location_${this.restaurantIdValue}`)
    const menuUrl = this.menuUrlValue || `/restaurants/${this.restaurantIdValue}/menu`
    window.location.href = menuUrl
  }

  updateStatus(message, type = "default") {
    const statusElement = document.getElementById('location-status')
    if (statusElement) {
      statusElement.textContent = message
      statusElement.className = "text-sm"
      
      if (type === "error") {
        statusElement.classList.add("text-red-600", "font-semibold")
      } else if (type === "success") {
        statusElement.classList.add("text-green-600", "font-semibold")
      } else if (type === "info") {
        statusElement.classList.add("text-blue-600", "font-semibold")
      } else {
        statusElement.classList.add("text-gray-600")
      }
    }
  }
}

