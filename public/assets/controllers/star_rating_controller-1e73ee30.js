import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="star-rating"
export default class extends Controller {
  static targets = []

  connect() {
    this.stars = this.element.querySelectorAll('.star-icon')
  }

  updateStars(event) {
    const selectedRating = parseInt(event.target.value)
    
    this.stars.forEach((star, index) => {
      const starNumber = parseInt(star.dataset.star)
      if (starNumber <= selectedRating) {
        star.classList.remove('text-gray-300')
        star.classList.add('text-yellow-400')
        star.setAttribute('fill', 'currentColor')
      } else {
        star.classList.remove('text-yellow-400')
        star.classList.add('text-gray-300')
        star.setAttribute('fill', 'none')
      }
    })
  }
}

