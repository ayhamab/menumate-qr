import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    const content = this.contentTarget
    const icon = this.iconTarget
    
    if (content.style.display === "none") {
      content.style.display = "block"
      icon.style.transform = "rotate(180deg)"
    } else {
      content.style.display = "none"
      icon.style.transform = "rotate(0deg)"
    }
  }
}

